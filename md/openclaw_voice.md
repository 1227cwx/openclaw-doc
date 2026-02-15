# 打通语音识别
<br/>
<div class="voice-intro">
OpenClaw 支持通过 Whisper 和 FFmpeg 实现语音转文字功能，让你可以通过语音与 AI 进行交互。
</div>

## 使用方法

当你在使用 OpenClaw 时，如果 AI 回复说没有办法或者无法做到语音识别等类似的话时，你可以这样引导它：

<div class="tip-box">
那你知道 Whisper 和 FFmpeg 吗？你为什么不能把这两者结合起来进行语音转文字的识别呢？
</div>

只要你的模型不是太蠢，大多数情况下它会明白你的意思，然后自动下载安装 Whisper 和 FFmpeg，并开始进行语音识别。

## 示例

<div class="image-gallery">
<img src="/voice-guide-1.jpg" alt="语音识别示例 1" class="voice-image" />
<img src="/voice-guide-2.jpg" alt="语音识别示例 2" class="voice-image" />
<img src="/voice-guide-3.jpg" alt="语音识别示例 3" class="voice-image" />
</div>

## 支持平台

<div class="platform-info">
<div class="platform-item">
<span class="platform-label">目前测试平台：</span>
<span class="platform-value">Telegram</span>
</div>
<div class="platform-item">
<span class="platform-label">其他平台：</span>
<span class="platform-value">暂待测试</span>
</div>
</div>

## 技术说明

<div class="tech-info">
<div class="tech-item">
<div class="tech-name">Whisper</div>
<div class="tech-desc">OpenAI 开源的语音识别模型，支持多种语言的语音转文字</div>
</div>
<div class="tech-item">
<div class="tech-name">FFmpeg</div>
<div class="tech-desc">强大的多媒体处理工具，用于音频格式转换和处理</div>
</div>
</div>

<div class="note">
OpenClaw 会自动处理这两个工具的安装和配置，你只需要按照上述方式引导 AI 即可。
</div>

<style>
.voice-intro {
  font-size: 1.1em;
  line-height: 1.8;
  color: var(--vp-c-text-1);
  margin-bottom: 2rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-left: 4px solid var(--vp-c-brand);
  border-radius: 8px;
}

.tip-box {
  font-size: 1.05em;
  line-height: 1.7;
  color: var(--vp-c-text-1);
  padding: 1.2rem 1.5rem;
  background: linear-gradient(135deg, var(--vp-c-brand-soft) 0%, var(--vp-c-brand-light) 100%);
  border-radius: 12px;
  border: 1px solid var(--vp-c-brand);
  margin: 1.5rem 0;
  font-weight: 500;
}

.image-gallery {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin: 2rem 0;
}

.voice-image {
  max-width: 60%;
  height: auto;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  margin: 0 auto;
  display: block;
}

.voice-image:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
}

.platform-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 1.5rem 0;
}

.platform-item {
  display: flex;
  align-items: center;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  border-left: 3px solid var(--vp-c-brand);
}

.platform-label {
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-right: 0.5rem;
}

.platform-value {
  color: var(--vp-c-brand);
  font-weight: 500;
}

.tech-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 1.5rem 0;
}

.tech-item {
  padding: 1.2rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 10px;
  border: 1px solid var(--vp-c-border);
  transition: all 0.3s ease;
}

.tech-item:hover {
  border-color: var(--vp-c-brand);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tech-name {
  font-size: 1.1em;
  font-weight: 600;
  color: var(--vp-c-brand);
  margin-bottom: 0.5rem;
}

.tech-desc {
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

.note {
  margin-top: 2rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  color: var(--vp-c-text-2);
  line-height: 1.7;
  font-style: italic;
}

@media (min-width: 768px) {
  .platform-info {
    flex-direction: row;
  }
  
  .platform-item {
    flex: 1;
  }
  
  .tech-info {
    flex-direction: row;
  }
  
  .tech-item {
    flex: 1;
  }
}
</style>
