import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  srcDir: "md",
  
  title: "openclaw使用文档",
  appearance: 'dark',
  description: "openclaw使用基础文档-完全开源免费的私人 AI 助手，通过 WhatsApp、Telegram、微信等聊天应用控制。支持 DeepSeek、豆包等国产 AI 模型，提供详细中文文档",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    outline: {
      label: '目录'
    },
    nav: [
      { text: '首页', link: '/' },
      { text: '阅读文档', link: '/openclaw_installation' }
    ],

    sidebar: [
      {
        text: '快速入门',
        items: [
          { text: '环境安装与配置', link: '/openclaw_installation' },
          { text: '常用命令手册', link: '/openclaw_commands' },
          { text: 'Mac Homebrew', link: '/openclaw_mac_homebrew' },
          { text: '接入本地大模型', link: '/openclaw_ollama' },
          { text: '中转 API 配置', link: '/openclaw_api_proxy' },
          { text: '插件与扩展', link: '/openclaw_plugins' }
        ]
      },
      {
        text: '高级部署',
        items: [
          { text: 'Linux 服务部署', link: '/openclaw_linux_deploy' }
        ]
      },
      /*{
        text: 'Examples',
        items: [
          { text: 'Markdown Examples', link: '/markdown-examples' },
          { text: 'Runtime API Examples', link: '/api-examples' }
        ]
      }*/
    ],

    socialLinks: [
     // { icon: 'wechat', link: 'https://github.com/vuejs/vitepress' }
    ]
  }
})
