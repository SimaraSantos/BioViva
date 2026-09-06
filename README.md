⚙️ Como Executar o Projeto Clonar o Repositório:

Bash git clone https://github.com/SimaraSantos/BioViva.git Abrir no Xcode:

Navegue até a pasta do projeto e abra o arquivo BioViva.xcodeproj ou BioViva.xcworkspace.

Executar no Simulador:

Selecione o dispositivo simulador desejado (ex: iPhone 17 Pro).

Pressione Cmd + R para rodar a aplicação.

Executar os Testes Unitários:

Pressione Cmd + U para rodar a suíte de testes do projeto (BioVivaTests).

🤝 Autor Desenvolvido por Simara Santos Silva como projeto de desenvolvimento iOS nativo em Swift. """

with open("README.md", "w", encoding="utf-8") as f: f.write(readme_bioviva)

print("README.md gerado com sucesso para BioViva!")

README.md gerado com sucesso para BioViva!

Your Markdown file is ready


README
 MD
 
 # BioViva 🌿🐦

**BioViva** é um aplicativo iOS nativo focado no registro, mapeamento e exploração da biodiversidade e avistamentos da fauna e flora. O projeto integra-se à API do **iNaturalist** para catalogar espécies (plantas, insetos, aves, etc.), permitindo visualização em lista detalhada e integração geográfica via mapa.

---

## 📱 Sobre o Projeto

O **BioViva** foi construído utilizando **Swift** e **UIKit**, seguindo a arquitetura MVC (Model-View-Controller) e boas práticas de desenvolvimento móvel. O app possui suporte a testes unitários, validação de novos avistamentos e navegação fluida entre telas através de Storyboards.

### 🚀 Funcionalidades

- **Listagem de Observações:** Exibição de avistamentos de espécies com foto, nome científico/comum, classificação (*Plantae*, *Insecta*, *Aves*, etc.) e data do registro.
- **Mapeamento Geográfico (`MapViewController`):** Visualização interativa dos pontos de avistamento registrados no mapa.
- **Registro de Novos Avistamentos (`NewSightingViewController`):** Formulário validado com regras de negócio para inserção de novas espécies observadas.
- **Detalhes da Observação (`ObservationDetailViewController`):** Tela focada nas informações completas de cada registro da biodiversidade.
- **Integração com API Externa:** Serviço voltado à integração com a plataforma **iNaturalist** (`iNaturalistService`).

---

## 🛠️ Tecnologias e Ferramentas Utilizadas

- **Linguagem:** Swift
- **Frameworks:** UIKit, MapKit, CoreLocation
- **Interface:** Storyboard / Interface Builder
- **Arquitetura:** MVC (Model-View-Controller)
- **Testes Unitários:** XCTest (Testes de Serviço e Validações)
- **IDE:** Xcode
- **Simulador:** iOS Simulator (iPhone 17 Pro)

---

## 📁 Estrutura do Projeto

```text
BioVivaApp/
├── BioViva/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Controllers/
│   │   ├── HomeViewController.swift
│   │   ├── ObservationsViewController.swift
│   │   ├── MapViewController.swift
│   │   ├── ObservationDetailViewController.swift
│   │   └── NewSightingViewController.swift
│   ├── Models/
│   ├── Services/
│   │   └── iNaturalistService.swift
│   ├── Stores/
│   ├── Assets.xcassets
│   └── Base.lproj/
│       ├── Main.storyboard
│       └── LaunchScreen.storyboard
└── BioVivaTests/
    ├── iNaturalistServiceTests.swift
    ├── NewSightingValidatorTests.swift
    └── Fixtures/
    
    ⚙️ Como Executar o Projeto
Clonar o Repositório:

Bash
git clone [https://github.com/SimaraSantos/BioViva.git](https://github.com/SimaraSantos/BioViva.git)
Abrir no Xcode:

Navegue até a pasta do projeto e abra o arquivo BioViva.xcodeproj.

Executar no Simulador:

Selecione o dispositivo simulador desejado (ex: iPhone 17 Pro).

Pressione Cmd + R para rodar a aplicação.

Executar os Testes Unitários:

Pressione Cmd + U para rodar a suíte de testes (BioVivaTests).

🤝 Autor
Desenvolvido por Simara Santos Silva como projeto de desenvolvimento iOS nativo em Swift.

