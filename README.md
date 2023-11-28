# amallo

Simple GUI to query a local Ollama API server for inference written in Flutter and manage large language models
- Add models from Ollama servers
- Create local models from Modelfile with template, parameter, adapter and license options
- Copy/Delete installed models
- View Modelfile information, including system prompt template and model parameters
- Save/Delete conversations

![screenshot](/screenshot.png) 

## Getting Started

1. Download and install [Ollama](https://ollama.ai/download)
2. Install [amallo](https://github.com/mthongvanh/amallo/releases) or,
3. Build from source.
```
   git clone git@github.com:mthongvanh/amallo.git
   cd amallo
   flutter pub get
   flutter run -d macos
```


Built with:

Flutter 3.13.2

Dart 3.1.0

Tested on:
macOS Sonoma (14.0) & Xcode 14.3.1
