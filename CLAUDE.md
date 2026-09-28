# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

Este repositório não é uma aplicação: é um espaço de trabalho para editar os vídeos da usuária por
conversa, usando a skill vendorizada **video-use** (`.claude/skills/video-use/`, upstream
`browser-use/video-use`, commit `b877063`). A usuária fala português do Brasil — responda em português.

Para qualquer pedido de edição de vídeo, invoque a skill `video-use` e siga o `SKILL.md` dela. As
**Hard Rules** de lá (legendas por último, extração por segmento + concat `-c copy`, fades de 30ms,
cortes em limites de palavra, confirmar a estratégia antes de cortar etc.) são obrigatórias.

## Onde ficam as coisas

- Vídeos brutos: numa pasta dentro do repo (ex.: `videos/`). Nunca modifique os originais.
- Saídas da sessão: sempre em `<pasta_dos_videos>/edit/` (`project.md`, `takes_packed.md`, `edl.json`,
  `transcripts/`, `preview.mp4`, `final.mp4`). Nunca escreva saídas dentro de `.claude/skills/video-use/`.
- `edit/project.md` é a memória entre sessões: leia-o ao começar e acrescente uma seção ao terminar.
- Não faça commit de vídeos brutos nem renderizados sem a usuária pedir (são grandes).

## Pipeline (helpers em `.claude/skills/video-use/helpers/`)

Fluxo de dados: fontes → `transcribe_batch.py` (ElevenLabs Scribe, word-level, cache em
`edit/transcripts/<nome>.json`) → `pack_transcripts.py --edit-dir <edit>` (gera `takes_packed.md`, a
principal visão de leitura) → decisões de corte em `edl.json` → `render.py <edl.json> -o <out>`
(extração por segmento com grade + fades → concat → overlays com PTS deslocado → legendas por último).
`timeline_view.py` (filmstrip + waveform) é para pontos de decisão e para auto-avaliação do render, não
para varrer tudo. `grade.py` é importado pelo `render.py` (presets / auto-grade).

```bash
H=.claude/skills/video-use/helpers
python3 $H/transcribe_batch.py videos/                 # transcreve tudo (4 workers, com cache)
python3 $H/pack_transcripts.py --edit-dir videos/edit
python3 $H/timeline_view.py <video> <inicio> <fim>
python3 $H/render.py videos/edit/edl.json -o videos/edit/preview.mp4 --preview
python3 $H/render.py videos/edit/edl.json -o videos/edit/final.mp4 --build-subtitles
```

Para falas em português, passe `--language pt` na transcrição (sem isso o Scribe detecta o idioma
automaticamente).

## Testes (só para mudanças nos helpers)

```bash
cd .claude/skills/video-use
python3 -m unittest discover -s tests                            # todos
python3 -m unittest tests.test_render_fps                        # um arquivo
python3 -m unittest tests.test_render_fps.ParseFpsTests          # uma classe
```

Os testes carregam `helpers/render.py` via `importlib` (não há pacote instalável). Para atualizar a
skill a partir do upstream, veja o README.

## Ambiente

- Na web, o hook `SessionStart` (`.claude/hooks/session-start.sh`, registrado em `.claude/settings.json`)
  instala `ffmpeg` e as libs Python (`requests librosa matplotlib pillow numpy`); ele só roda quando
  `CLAUDE_CODE_REMOTE=true`.
- `ELEVENLABS_API_KEY` é lida do ambiente ou de `.claude/skills/video-use/.env` (ignorado pelo git).
  O jeito preferido é cadastrá-la como variável de ambiente nas configurações do ambiente cloud.
- A transcrição exige acesso de rede a `api.elevenlabs.io`; se o proxy recusar, a usuária precisa
  liberar esse domínio no Network access do ambiente.
