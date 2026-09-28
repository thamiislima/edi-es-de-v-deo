# edições de vídeo

Repositório para editar vídeos por conversa com o Claude Code, usando a skill
[video-use](https://github.com/browser-use/video-use) (commit `b877063`), instalada em
`.claude/skills/video-use/`.

## Como usar

1. Coloque os vídeos brutos numa pasta (ex.: `videos/`).
2. Peça ao Claude: *"edite esses vídeos em um vídeo de lançamento"* ou
   *"faça um inventário dos takes e proponha uma estratégia"*.
3. Os resultados ficam em `<pasta_dos_videos>/edit/` (ex.: `edit/final.mp4`).

## Requisitos

- `ffmpeg`/`ffprobe` e as libs Python (`requests librosa matplotlib pillow numpy`) —
  instalados automaticamente nas sessões web pelo hook `.claude/hooks/session-start.sh`.
- **Chave da ElevenLabs** (`ELEVENLABS_API_KEY`) para transcrição. Configure-a como
  variável de ambiente/segredo do ambiente — nunca faça commit dela.

## Atualizar a skill

```bash
git clone --depth 1 https://github.com/browser-use/video-use /tmp/video-use
cp -r /tmp/video-use/{SKILL.md,install.md,helpers,skills,pyproject.toml} .claude/skills/video-use/
```
