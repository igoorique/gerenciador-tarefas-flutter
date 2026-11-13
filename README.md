# Gerenciador de Tarefas Inteligente (Flutter)

Trabalho **Explorando Tecnologias Móveis** · Unochapecó · Prof. Cezar Junior de Souza

App de tarefas feito em **Flutter/Dart**, com categorias, prioridades, prazos, busca, filtros e dados salvos no próprio aparelho. A parte "inteligente" é um assistente que funciona offline: ele lê o que você digita e sugere a categoria e a prioridade da tarefa.

## Funcionalidades

| Requisito do trabalho | Como funciona no app |
|---|---|
| Criar, editar e excluir | Botão **Nova tarefa**; toque no card para editar; deslize o card para a esquerda para excluir (com **Desfazer**) ou use a lixeira na tela de edição |
| Categorizar | Trabalho, Estudo, Pessoal, Saúde e Outros |
| Prioridades | Alta, Média e Baixa, com cores e ordenação |
| Marcar como concluída | Checkbox no card e barra de progresso no topo |
| Buscar e filtrar | Busca que ignora acentos, mais filtros por situação, prioridade e categoria |
| Persistência local | `shared_preferences` com JSON (Android, iOS e web) |

**Recursos "inteligentes"**

- Sugere categoria e prioridade pelo texto. Ex.: *"Estudar para a prova de cálculo amanhã"* → **Estudo · Alta**.
- Prazo para hoje ou amanhã eleva a prioridade para **Alta**; prazo em até 3 dias, para no mínimo **Média**.
- Ordena sozinho: pendentes primeiro, depois prioridade, prazo e as mais recentes.
- Destaca as tarefas atrasadas.

## Como rodar

Pré-requisito: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e `flutter doctor` sem erros na plataforma que você vai usar.

```bash
# 1. Gerar as pastas de plataforma (android/, ios/, web/), só na primeira vez.
#    Não sobrescreve os arquivos do projeto; só cria o que está faltando.
flutter create --project-name gerenciador_tarefas --platforms=android,ios,web .

# 2. Baixar as dependências
flutter pub get

# 3. Rodar no emulador ou no celular...
flutter run
# ...ou no navegador
flutter run -d chrome
```

Com o app rodando no terminal: **r** = hot reload, **R** = hot restart, **q** = sair.

> **Flutter 3.50 ou mais novo:** o editor pode marcar `package:flutter/material.dart` e os delegates de tradução como obsoletos, porque o Material virou o pacote separado `material_ui`. São só avisos: o app compila e roda normalmente. Os imports antigos foram mantidos para o projeto funcionar também em versões anteriores do Flutter.
>
> **Não aceite** o `dart fix --apply` nem a correção rápida de "migrar" sugerida pelo editor antes de adicionar os pacotes novos: misturar `material.dart` com `material_ui` gera erro de import ambíguo. Para migrar de vez, siga o [guia oficial](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).

## Testes

```bash
flutter test
```

São três arquivos em `test/`: regras do assistente, estado/persistência (provider e modelo) e um teste de interface que cria uma tarefa pelo formulário.

## Build

```bash
flutter build apk --release          # APK único
flutter build apk --split-per-abi    # APKs menores, um por arquitetura
flutter build appbundle              # .aab para a Google Play
flutter build ipa                    # iOS (exige macOS + Xcode)
flutter build web                    # site estático em build/web
```

O APK fica em `build/app/outputs/flutter-apk/`.

## Estrutura

```
lib/
├── main.dart                        # MaterialApp, tema, idioma pt-BR e Provider
├── models/tarefa.dart               # Tarefa, Categoria e Prioridade (+ JSON)
├── providers/tarefa_provider.dart   # Estado: CRUD, busca, filtros e ordenação
├── services/tarefa_repository.dart  # Persistência com shared_preferences
├── utils/
│   ├── assistente_tarefas.dart      # Sugestões "inteligentes" (palavras-chave + prazo)
│   ├── datas.dart                   # Formatação de datas e cálculo de dias
│   └── texto.dart                   # Normalização (minúsculas, sem acento)
├── ui/aparencia.dart                # Ícones e cores de categorias e prioridades
├── screens/
│   ├── home_screen.dart             # Lista, resumo, busca e filtros
│   └── tarefa_form_screen.dart      # Criar e editar tarefa
└── widgets/                         # Card, etiqueta, barra de filtros, resumo
test/                                # Testes de unidade e de widget
```

## Arquitetura

```
Telas (widgets) ──context.watch──▶ TarefaProvider (ChangeNotifier)
       ▲                                  │
       └──── notifyListeners() ◀──────────┤  ações: adicionar, concluir, filtrar...
                                          ▼
                              TarefaRepository ──▶ shared_preferences (JSON)
```

## Publicar no GitHub

Depois do passo 1 de "Como rodar" (para incluir as pastas android/, ios/ e web/), crie um repositório **vazio** em https://github.com/new e rode:

```bash
git init
git add .
git commit -m "Gerenciador de Tarefas Inteligente em Flutter"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/gerenciador-tarefas-flutter.git
git push -u origin main
```
