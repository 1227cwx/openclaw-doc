#!/usr/bin/env python3
"""AIVectorMemory HTTP API - 多 agent 通过 tags 隔离记忆"""
import json, sys, threading, time
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from aivectormemory.db import ConnectionManager, init_db
from aivectormemory.embedding.engine import EmbeddingEngine
from aivectormemory.tools import TOOL_HANDLERS

PROJECT_DIR = "/root/.aivectormemory"
API_PORT = 9081

def log_request(method, path, args, agent_tag=None, duration_ms=None):
    """输出请求日志"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    agent_info = f" | agent: {agent_tag}" if agent_tag else ""
    duration_info = f" | {duration_ms:.0f}ms" if duration_ms else ""
    args_str = json.dumps(args, ensure_ascii=False)[:200] if args else ""
    print(f"[{timestamp}] {method} {path}{agent_info}{duration_info} | {args_str}", flush=True)

thread_local = threading.local()

def get_db_connection():
    if not hasattr(thread_local, 'cm') or thread_local.cm is None:
        cm = ConnectionManager(project_dir=PROJECT_DIR)
        engine = EmbeddingEngine()
        init_db(cm.conn, engine=engine)
        cm._embedding_engine = engine
        thread_local.cm = cm
        thread_local.engine = engine
    return thread_local.cm, thread_local.engine

class APIHandler(BaseHTTPRequestHandler):
    def log_message(self, *a): pass

    def send_json(self, data, code=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        
        # 请求日志
        if hasattr(self, '_start_time'):
            duration_ms = (time.time() - self._start_time) * 1000
            agent = getattr(self, '_agent_tag', '')
            method = getattr(self, '_method', 'POST')
            path = self.path
            log_request(method, path, {"response": data}, agent, duration_ms)

    def read_body(self):
        n = int(self.headers.get("Content-Length", 0))
        if n == 0:
            return {}
        try:
            return json.loads(self.rfile.read(n))
        except:
            return {}

    def get_agent_tag(self, args):
        agent_id = args.get("agent_tag", "default")
        if agent_id.startswith("agent:"):
            return agent_id
        return f"agent:{agent_id}"

    def do_GET(self):
        self._start_time = time.time()
        self._method = "GET"
        if self.path == "/health":
            self.send_json({"ok": True, "project": PROJECT_DIR, "port": API_PORT})
        else:
            self.send_json({"error": "not found"}, 404)

    def do_POST(self):
        self._start_time = time.time()
        self._method = "POST"
        
        tool = self.path.lstrip("/")
        handler = TOOL_HANDLERS.get(tool)
        if not handler:
            self.send_json({"error": f"unknown tool: {tool}"}, 404)
            return
        
        try:
            args = self.read_body()
            agent_tag = args.get("agent_tag", "")
            if not agent_tag:
                self.send_json({"error": "必须带上你的个人标识"}, 400)
                return
            
            self._agent_tag = agent_tag
            agent_tag = self.get_agent_tag(args)
            args.pop("agent_tag", None)
            
            # 获取数据库连接
            cm, engine = get_db_connection()
            
            if tool == "remember":
                tags = args.get("tags", [])
                if agent_tag not in tags:
                    tags.append(agent_tag)
                args["tags"] = tags
                result = handler(args, cm=cm, engine=engine, session_id=1)
                response = {"stored_tags": tags}
                if result:
                    import json
                    try:
                        response.update(json.loads(result))
                    except:
                        response["raw"] = result
                self.send_json(response)
                return
            
            elif tool == "recall":
                existing_tags = args.get("tags", [])
                if agent_tag not in existing_tags:
                    existing_tags.append(agent_tag)
                args["tags"] = existing_tags
                result = handler(args, cm=cm, engine=engine, session_id=1)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            elif tool == "forget":
                if "memory_id" not in args and "memory_ids" not in args:
                    args["tags"] = [agent_tag]
                result = handler(args, cm=cm, engine=engine, session_id=1)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            elif tool == "status":
                session_id = agent_tag.replace(":", "-")
                result = handler(args, cm=cm, engine=engine, session_id=session_id)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            elif tool == "track":
                tags = args.get("tags", [])
                if agent_tag not in tags:
                    tags.append(agent_tag)
                args["tags"] = tags
                result = handler(args, cm=cm, engine=engine, session_id=1)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            elif tool == "task":
                tags = args.get("tags", [])
                if agent_tag not in tags:
                    tags.append(agent_tag)
                args["tags"] = tags
                result = handler(args, cm=cm, engine=engine, session_id=1)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            elif tool == "auto_save":
                extra_tags = args.get("extra_tags", [])
                if agent_tag not in extra_tags:
                    extra_tags.append(agent_tag)
                args["extra_tags"] = extra_tags
                result = handler(args, cm=cm, engine=engine, session_id=1)
                import json
                try:
                    self.send_json(json.loads(result))
                except:
                    self.send_json(result if result else {"ok": True})
                return
            
            result = handler(args, cm=cm, engine=engine, session_id=1)
            import json
            try:
                self.send_json(json.loads(result))
            except:
                self.send_json(result if result else {"ok": True})
        except Exception as e:
            self.send_json({"error": str(e)}, 500)

if __name__ == "__main__":
    print(f"[aivector-api] 启动成功：http://0.0.0.0:{API_PORT}", file=sys.stderr, flush=True)
    HTTPServer(("0.0.0.0", API_PORT), APIHandler).serve_forever()
