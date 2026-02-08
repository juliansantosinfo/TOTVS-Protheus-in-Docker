# TOTVS Protheus in Docker - System Instructions

Este projeto é uma implementação dockerizada do ERP TOTVS Protheus em microserviços. Como agente neste projeto, você deve seguir estas diretrizes:

## 1. Gestão de Versões
- **Arquivo Central**: O arquivo `versions.env` na raiz é a única fonte de verdade para versões de serviços (`*_VERSION`), nomes de imagens (`*_IMAGE_NAME`) e o usuário Docker (`DOCKER_USER`).
- **Validação**: Sempre que alterar versões em `versions.env` ou nos `dockerfile`, você DEVE executar `./scripts/validation/versions.sh --fix` para garantir a sincronia.

## 2. Padrões de Commit
- **Conventional Commits**: Utilize estritamente o padrão Conventional Commits (ex: `feat:`, `fix:`, `docs:`, `ci:`, `chore:`).
- **Hooks**: O projeto possui Git Hooks configurados (`pre-commit` e `commit-msg`). Nunca use `--no-verify` a menos que seja estritamente necessário para lidar com falsos positivos de segredos em arquivos de exemplo/teste.

## 3. Scripts de Automação
- Sempre prefira usar os scripts em `scripts/` para tarefas comuns:
    - `scripts/build/setup.sh`: Preparar ambiente.
    - `scripts/build/build.sh`: Build de imagens.
    - `scripts/build/push.sh`: Publicação no Docker Hub.
    - `scripts/hooks/install.sh`: Reinstalar hooks se necessário.

## 4. Documentação
- A documentação oficial reside em `docs/v1.0/`. Mantenha-a atualizada ao adicionar novas funcionalidades ou alterar fluxos operacionais.

## 5. Segurança
- Nunca exponha senhas reais. Utilize as senhas de exemplo padrão do projeto (`ProtheusDatabasePassword1`) apenas para fins de demonstração em ambientes de dev/test.
