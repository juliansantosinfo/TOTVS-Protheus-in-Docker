# Documentação - TOTVS Protheus in Docker

Bem-vindo à central de documentação técnica do projeto **TOTVS Protheus in Docker**.

Selecione abaixo a versão da documentação de acordo com sua necessidade:

---

## 🌟 [Versão 3.0 (Atual e Recomendada)](./v3.0/README.md)
A documentação oficial e mais completa do projeto. Estruturada segundo o framework **Diátaxis**, reflete o estado maduro da stack:
- **Release 12.1.2610** (AppServer 26.3.0.0, DBAccess 26.1.0.0, LicenseServer 3.7.2, SmartView 3.9.0).
- Suporte completo a múltiplos bancos (**PostgreSQL**, **Microsoft SQL Server**, **Oracle Database**).
- Modos do AppServer: `application`, `rest` e `sqlite` (LocalFiles de alta performance).
- Automação de ciclo de vida com Git Submodules, hooks de integridade e scripts de transição de release (`branch-checkout.sh`).
- Ecossistema de ferramentas web (Compose Generator & Dockerfile Generator) e integração com agentes de IA (`.agents/`).

*👉 [Acessar a Documentação v3.0](./v3.0/README.md)*

---

## 📦 [Versão 2.0 (Transição Modular)](./v2.0/README.md)
Documentação da fase de transição para **Git Submodules**, centralização de versões no `versions.env` e pipelines iniciais de CI/CD (GitHub Actions).

*👉 [Acessar a Documentação v2.0](./v2.0/README.md)*

---

## 🏛️ [Versão 1.0 (Legado)](./v1.0/README.md)
Documentação clássica do projeto em arquitetura monolítica (mono-repo). Mantida para referência histórica de configurações e conceitos fundacionais de containerização.

*👉 [Acessar a Documentação v1.0](./v1.0/README.md)*
