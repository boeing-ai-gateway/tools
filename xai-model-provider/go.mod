module github.com/boeing-ai-gateway/tools/xai-model-provider

go 1.26.2

replace github.com/boeing-ai-gateway/tools/openai-model-provider => ../openai-model-provider

require github.com/boeing-ai-gateway/tools/openai-model-provider v0.0.0

require github.com/gptscript-ai/chat-completion-client v0.0.0-20250123123106-c86554320789 // indirect
