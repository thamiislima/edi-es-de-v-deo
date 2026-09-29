# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

Repositório para editar vídeos por conversa, usando a skill vendorizada
[video-use](https://github.com/browser-use/video-use) em `.claude/skills/video-use/` e a
API da ElevenLabs (Scribe) para transcrição com timestamps por palavra. Localmente, a
usuária mantém o projeto em `C:\Users\thami\Developer\video-use` (Windows).

**Para qualquer pedido de edição de vídeo, carregue a skill `video-use` e siga o
`SKILL.md` dela** — ele define o processo (inventário → conversa → estratégia confirmada
→ execução → auto-avaliação → persistência em `project.md`) e as *Hard Rules* de
correção de produção (legendas por último, concat `-c copy`, fades de 30ms, cortes
só em limites de palavra, etc.). Nunca execute cortes antes de a usuária aprovar a
estratégia em texto.

## Estrutura

- `.claude/skills/video-use/helpers/` — scripts Python (ffmpeg + PIL/librosa) que fazem
  todo o trabalho:
  - `transcribe.py` / `transcribe_batch.py` → chamam o ElevenLabs Scribe (`scribe_v1`) e
    cacheiam o JSON bruto em `<videos_dir>/edit/transcripts/<nome>.json`. Nunca
    retranscreva uma fonte que não mudou (custa créditos).
  - `pack_transcripts.py` → junta os transcripts em `takes_packed.md`, a principal
    visão de leitura para decidir cortes.
  - `timeline_view.py` → PNG de filmstrip + waveform de um intervalo, para inspeção
    visual pontual.
  - `render.py` → lê `edl.json` (`sources`, `ranges`, overlays, `subtitles`, grade),
    extrai cada segmento, concatena, aplica overlays e por fim legendas; loudnorm
    -14 LUFS por padrão.
  - `grade.py` → color grade via cadeia de filtros ffmpeg (presets ou `--filter`).
- `.claude/skills/video-use/skills/manim-video/` — sub-skill para overlays em Manim.
- `.claude/hooks/session-start.sh` — em sessões web (`CLAUDE_CODE_REMOTE=true`) instala
  `ffmpeg` e as libs Python (`requests librosa matplotlib pillow numpy`).

Todas as saídas de uma sessão de edição vão para `<videos_dir>/edit/` (ex.:
`videos/edit/final.mp4`); nunca escreva dentro de `.claude/skills/video-use/`.

## Comandos

Os helpers resolvem caminhos relativos a si mesmos; rode-os com `python3`:

```bash
H=.claude/skills/video-use/helpers
python3 $H/transcribe_batch.py videos/                 # transcreve tudo (4 workers)
python3 $H/transcribe.py videos/take1.mp4 --language pt  # uma fonte; sem --language = auto
python3 $H/pack_transcripts.py --edit-dir videos/edit
python3 $H/timeline_view.py videos/take1.mp4 12.0 18.5 -o videos/edit/verify/t.png
python3 $H/render.py videos/edit/edl.json -o videos/edit/preview.mp4 --preview --build-subtitles
python3 $H/render.py videos/edit/edl.json -o videos/edit/final.mp4 --build-subtitles
```

`render.py`: `--draft` = 720p ultrafast (só verificar cortes), `--preview` = 1080p
CRF 22 (QC), sem flag = final. Outras flags: `--fps`, `--no-subtitles`, `--no-loudnorm`.

Testes (unittest, só cobrem `render.py`):

```bash
cd .claude/skills/video-use
python3 -m unittest discover -s tests                        # todos
python3 -m unittest tests.test_render_fps                    # um arquivo
python3 -m unittest tests.test_render_fps.ParseFpsTests      # uma classe
```

## Chave da ElevenLabs

`transcribe.py` procura `ELEVENLABS_API_KEY` em `.claude/skills/video-use/.env`, depois
em `./.env`, depois na variável de ambiente. Em sessões web, configure-a como segredo do
ambiente. `.env` está no `.gitignore` — nunca faça commit da chave.

## Atualizar a skill

A skill está fixada no commit `b877063` do upstream. Para atualizar:

```bash
git clone --depth 1 https://github.com/browser-use/video-use /tmp/video-use
cp -r /tmp/video-use/{SKILL.md,install.md,helpers,skills,pyproject.toml} .claude/skills/video-use/
```

Prefira não editar os helpers localmente para não divergir do upstream.
