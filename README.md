# AI Summary
SwiftUI app based on [langchain-swift](https://github.com/buhe/langchain-swift).

## Get started
Edit your https://github.com/buhe/AISummary/blob/main/ShareExt/env.txt, set your openai_key.

If you find it troublesome or want to support me, go to [https://apps.apple.com/us/app/ai-pagily/id6452588389](https://apps.apple.com/us/app/ai-summarize-pro/id6450951898)

## Core Code
```swift
  let loader = YoutubeLoader(video_id: video_id, language: lang)
  let doc = await loader.load()
  let p = """
YouTubeビデオの字幕は次のとおりです:%@、メインコンテンツを100語以内に要約してください。
"""
  let prompt = PromptTemplate(input_variables: ["youtube"], template: p)
  let request = prompt.format(args: [String(doc.first!.page_content.prefix(2000))])
  let llm = OpenAI()
  let reply = await llm.send(text: request)
```
