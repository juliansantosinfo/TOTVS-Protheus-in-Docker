# Manual de Referência Técnica e Operacional
## TOTVS Protheus in Docker
**Versão da Documentação:** 2.0
**Data:** Março de 2026

---

# 1. Introdução

## 1.1. Sobre este Documento
Este documento serve como o manual definitivo para a versão 2.0 do projeto **TOTVS Protheus in Docker**. Ele foi elaborado para cobrir todos os aspectos do ciclo de vida do projeto, refletindo sua evolução para uma arquitetura modular baseada em submódulos Git e automação avançada de CI/CD.

O objetivo é fornecer uma fonte de conhecimento exaustiva que permita a qualquer profissional de TI — seja um desenvolvedor, analista de infraestrutura ou engenheiro de DevOps — compreender profundamente como o ERP TOTVS Protheus foi adaptado para rodar de forma escalável em containers.

## 1.2. Visão Geral do Projeto (v2.0)
O projeto **TOTVS Protheus in Docker** moderniza a implantação do ERP TOTVS Protheus, transformando-o em um ecossistema flexível baseado em Docker.

Na versão 2.0, o projeto adota uma filosofia de **Modularidade Extrema**. O repositório principal atua como um maestro (orquestrador), enquanto cada microserviço (AppServer, DbAccess, etc.) é mantido em seu próprio repositório Git isolado e integrado via **Git Submodules**.

### Principais Benefícios da v2.0:
1.  **Modularidade:** Manutenção e versionamento isolados por serviço. Um bug no DBAccess não impacta a esteira do AppServer.
2.  **Orquestração Centralizada:** Scripts mestres na raiz do projeto compilam, limpam e distribuem imagens para todos os submódulos de forma unificada.
3.  **CI/CD Robusto:** Pipelines rigorosos no GitHub Actions garantem a qualidade do código (ShellCheck, Hadolint) e realizam smoke tests automatizados antes do push para o Docker Hub.
4.  **"Infraestrutura como Código" (IaC):** Todo o ambiente é definido através de `Dockerfiles` e gerido por um arquivo central de versões (`versions.env`).

## 1.3. Escopo e Limitações
Este projeto foca em fornecer a melhor experiência para **ambientes de Desenvolvimento, Homologação, Testes Automatizados e CI/CD**.

Embora as imagens baseadas em Enterprise Linux (UBI/Oracle Linux) sejam extremamente seguras e robustas, a implantação em **Produção Míssil Crítica** exige topologias adicionais (Kubernetes, persistência distribuída de RPO, clusterização de banco avançada) que vão além do escopo de um simples `docker-compose`.

**Aviso Legal:** Este é um projeto independente e open-source, sem filiação oficial com a TOTVS S/A. O uso é regido pela licença MIT.

## 1.4. Público Alvo
*   **Desenvolvedores ADVPL/TLPP:** Que precisam de ambientes locais instantâneos e garantidos para codificação.
*   **Engenheiros Cloud/DevOps:** Que gerenciam pipelines de CI/CD e infraestruturas escaláveis para o Protheus.
*   **Consultores Técnicos:** Que necessitam de instâncias idênticas às dos clientes em segundos.
