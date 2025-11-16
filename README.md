# Gerenciador de times

Um aplicativo Flutter simples e intuitivo para **gerenciar jogadores** e
**sortear times** automaticamente. Ideal para jogos de futebol,
basquete, vôlei ou qualquer atividade esportiva que envolva equipes
equilibradas.

------------------------------------------------------------------------

## Funcionalidades

### Gerenciamento de Jogadores

-   Adicionar jogadores com nome.
-   Remover jogadores.
-   Visualizar lista completa de participantes.

### Sorteio de Times

-   Define automaticamente duas equipes equilibradas.
-   Embaralha jogadores utilizando algoritmos simples de randomização.
-   Exibe os times formados na tela de forma clara.

------------------------------------------------------------------------

## Estrutura do Projeto

    lib/
     ├── main.dart
     ├── view/
     │    ├── home_view.dart
     │    ├── jogadores_view.dart
     │    ├── sorteio_view.dart
     ├── viewmodel/
     │    ├── jogador_viewmodel.dart
     │    ├── sorteio_viewmodel.dart
     ├── model/
     │    └── jogador.dart

------------------------------------------------------------------------

## Identidade Visual

-   Logo minimalista voltada à prática de esportes.
-   Nome do app configurado via
    `android/app/src/main/AndroidManifest.xml` e
    `ios/Runner/Info.plist`.

------------------------------------------------------------------------

## Tecnologias Utilizadas

-   **Flutter**
-   **Provider (State Management)**
-   **Dart**
-   **Material Design**

------------------------------------------------------------------------

## 📦 Estrutura de Diretórios Recomendada

    lib/
     ├── model/
     ├── view/
     ├── viewmodel/
     ├── widgets/

------------------------------------------------------------------------
