# AI video tools for your PC (Windows)

| Tool | What it does | Repo |
|---|---|---|
| **MoneyPrinterTurbo** | Topic or keyword → finished short video (script, stock footage, voice-over, subtitles, music) | [harry0703/MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) |
| **SupoClip** | Long video in → viral short clips out (an open-source OpusClip alternative) | [FujiwaraChoki/supoclip](https://github.com/FujiwaraChoki/supoclip) |
| **Freefield** | 120 image, video, VFX and audio apps on ComfyUI, all open-weight models | [neuregex/freefield](https://github.com/neuregex/freefield) |

## 1. Install

1. Download this `pc-setup` folder to your PC.
2. Double-click **`setup.cmd`**.

The script uses `winget` to install anything that's missing (Git, Python 3.11, Node 22, Docker Desktop). It then puts all three tools in `%USERPROFILE%\ai-tools` and copies the `start-*.bat` launchers there.

To leave a tool out, run `setup.cmd -Skip Freefield`. Freefield is the one you're most likely to skip, because it needs a big GPU or a Modal account.

## 2. Add API keys, then start

### MoneyPrinterTurbo (easiest: works on any PC)
- Start it with `start-moneyprinterturbo.bat`. The WebUI opens in your browser.
- In **Basic Settings**, add:
  - an LLM key (OpenAI, DeepSeek, Gemini, or a local Ollama)
  - a free [Pexels](https://www.pexels.com/api/) key for stock footage
- Finished videos are saved in `%LOCALAPPDATA%\MoneyPrinterTurbo\storage\tasks`.

### SupoClip (needs Docker Desktop running)
- Edit `%USERPROFILE%\ai-tools\supoclip\.env`:
  - Transcription: set `ASSEMBLY_AI_API_KEY=...`, **or** set `TRANSCRIPTION_PROVIDER=whisper` to transcribe locally for free.
  - Clip picking: set the `LLM=` line plus that provider's key. For example, `LLM=openai:gpt-5.2` with `OPENAI_API_KEY=...`, or `LLM=ollama:gpt-oss:20b` with Ollama for a fully local, free setup.
- Start it with `start-supoclip.bat`. The first build takes 10+ minutes. The app runs at http://localhost:3107.

### Freefield (heavy: needs a GPU)
You need one of these:
- **A [Modal](https://modal.com) account** (cloud GPU, pay per second, with free monthly credit):
  ```powershell
  cd $env:USERPROFILE\ai-tools\freefield
  python tools/setup_token.py
  modal secret create huggingface HF_TOKEN=hf_...
  modal run infra/modal_app.py::download --pack image
  modal deploy infra/modal_app.py      # put the printed URL in .env as COMFY_BASE_URL
  ```
- **Your own NVIDIA GPU** (24 GB VRAM for most apps): install PyTorch with CUDA, then follow *"On your own GPU, without Modal"* in the Freefield README.

Run `python tools/doctor.py` at any time to see what's still missing. When it's ready, start it with `start-freefield.bat`. The app runs at http://127.0.0.1:3000.
