# Manual de Referência Técnica e Operacional
## TOTVS Protheus in Docker
**Versão da Documentação:** 1.0
**Data:** Fevereiro de 2026

---

# 1. Introdução

## 1.1. Sobre este Documento
Este documento serve como o manual definitivo para o projeto **TOTVS Protheus in Docker**. Ele foi elaborado para cobrir todos os aspectos do ciclo de vida do projeto, desde a concepção arquitetural até os procedimentos de operação diária, manutenção e expansão.

O objetivo é fornecer uma fonte de conhecimento exaustiva que permita a qualquer profissional de TI — seja um desenvolvedor, analista de infraestrutura ou arquiteto de software — compreender profundamente como o ERP TOTVS Protheus foi adaptado para rodar em uma arquitetura de microserviços containerizada.

## 1.2. Visão Geral do Projeto
O projeto **TOTVS Protheus in Docker** é uma iniciativa que visa modernizar a implantação e execução do ERP TOTVS Protheus, tradicionalmente monolítico e complexo de configurar, transformando-o em um ecossistema flexível, escalável e portátil baseado em Docker.

A principal filosofia adotada é a de **"Infraestrutura como Código" (IaC)**, onde todo o ambiente — servidores de aplicação, bancos de dados, servidores de licença e gateways — é definido através de arquivos de configuração versionáveis (`Dockerfiles`, `docker-compose.yaml`, scripts Shell).

### Principais Benefícios:
1.  **Padronização:** Elimina o problema de "funciona na minha máquina". Todos os desenvolvedores e ambientes de teste rodam exatamente as mesmas versões de binários e configurações.
2.  **Agilidade:** A criação de um novo ambiente completo, que antes levava horas ou dias, é reduzida para minutos (ou segundos, após o primeiro build).
3.  **Isolamento:** Cada componente roda em seu próprio container, evitando conflitos de dependências (DLLs, bibliotecas do sistema operacional, portas).
4.  **Facilidade de Teste:** Permite testar diferentes versões do Protheus (RPO, binários) ou bancos de dados (MSSQL vs PostgreSQL) simplesmente alterando uma variável de ambiente.

## 1.3. Escopo e Limitações
Este projeto foca em **ambientes de Desenvolvimento, Homologação e Testes**.
Embora a arquitetura utilize práticas robustas, o uso em **Produção** exige cuidados adicionais que podem não estar cobertos por padrão nesta implementação (como alta disponibilidade de banco de dados, backups complexos, clusters Kubernetes gerenciados, etc.).

**Aviso Legal:** Este é um projeto independente e open-source, sem filiação oficial com a TOTVS S/A. O uso é regido pela licença MIT.

## 1.4. Público Alvo
*   **Desenvolvedores ADVPL/TLPP:** Que precisam de ambientes locais rápidos para codificação e teste.
*   **Analistas de Infraestrutura/DevOps:** Que desejam automatizar o deploy do Protheus ou migrá-lo para arquiteturas de nuvem.
*   **Consultores TOTVS:** Que necessitam de ambientes portáteis para demonstrações ou validações em clientes.
