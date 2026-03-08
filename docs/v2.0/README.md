# Manual Completo - TOTVS Protheus in Docker (v2.0)

Bem-vindo à documentação oficial da versão **2.0** do projeto TOTVS Protheus in Docker.
Esta biblioteca de documentos consolida o estágio avançado e maduro da arquitetura do projeto: **A Era Modular e CI/CD Continuous Delivery.**

Aqui você aprenderá como orquestrar múltiplos microsserviços do ERP de forma harmoniosa utilizando Git Submodules e scripts mestres.

## Índice da Documentação v2.0

1.  [**Introdução (Evolução para Modularidade)**](./01_Introducao.md)
    *   Sobre este Documento
    *   Visão Geral do Projeto (v2.0)
    *   Benefícios da Nova Arquitetura Modular
    *   Público Alvo Atendido

2.  [**Arquitetura do Sistema Integrado**](./02_Arquitetura.md)
    *   Arquitetura Orientada a Submódulos Git (Mono-repo vs Multi-repo)
    *   A "Fonte a Única de Verdade" (`versions.env`)
    *   Detalhamento Avançado dos Componentes (Banco Inteligente, DBAccess Resiliente, AppServer Múltiplo)
    *   Estratégia "Snapshots" (Pré-Carregamento via `setup.sh`)

3.  [**Instalação e Construção (Build Master)**](./03_Instalacao.md)
    *   Clonando com Submódulos (`--recursive`)
    *   Configuração do Ambiente via Motor de Download Orquestrado (`setup.sh`)
    *   A Construção Modular Orquestrada (`build.sh` global)
    *   Inicialização Simplificada (Deploy com Profiles e Docker Compose)

4.  [**Manual Operacional na Nuvem de Contêineres**](./04_Manual_Operacional.md)
    *   Orquestradores Diários (Script `clean.sh`)
    *   Tabela de Portas TCP/IP
    *   Monitoramento Centralizado (Scripts de Validação Pós-Push)
    *   Atualização de RPOs a frio VS Bind Mounts

5.  [**Manutenção, Pipeline CI/CD e Governança**](./05_Manutencao_e_Desenvolvimento.md)
    *   Gerenciando o Github Actions Pipeline (`.github/workflows/deploy.yml`)
    *   Code Review e Validador do "Cão de Guarda" de versões.
    *   Como interagir isoladamente com repositórios e atualizar Hash de Commits Root.
    *   Scripts Master em Detalhe (ex. `push.sh` root).

6.  [**Solução de Problemas (Troubleshooting Avançado)**](./06_Solucao_de_Problemas.md)
    *   Crash 1: O Vazio dos Submódulos Git
    *   Crash 2: Permissões de Execução Linux Bloqueadas Em Massa
    *   Crash 3: Conflitos de Hook do Versions.Env desalinhado
    *   Limites Operacionais Nativos e Problemas Clássicos (Wait on Connection Refused).

---
*Documentação Oficial atualizada via IA (Antigravity Agent) para alinhamento da Release v2.0 - Março/2026. Reflete o commit atual da Branch Central TOTVS-Protheus-in-Docker.*
