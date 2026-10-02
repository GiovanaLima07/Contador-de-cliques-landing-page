Template estático de loja de móveis planejados, construído com **Vite + Bootstrap 5 + SCSS**.

https://giovanalima07.github.io/Contador-de-cliques-landing-page/index.html

---

## Tecnologias

| Pacote | Versão | Papel |
|---|---|---|
| [Vite](https://vitejs.dev/) | ^6 | Dev server e bundler |
| [Bootstrap](https://getbootstrap.com/) | ^5.3 | UI e layout |
| [Bootstrap Icons](https://icons.getbootstrap.com/) | ^1.13 | Ícones |
| [Swiper](https://swiperjs.com/) | ^12 | Carousel/slider |
| [Sass](https://sass-lang.com/) | ^1.77 | Pré-processador CSS |

---

## Estrutura

```
src/
├── index.html               # Home (com slider Swiper)
├── about.html               # Sobre
├── contact.html             # Contato
├── products.html            # Listagem de produtos
├── 1_produto-comoda.html    # Detalhe de produto
├── assets/
│   ├── images/              # Imagens dos produtos
│   ├── js/
│   │   ├── main.js          # Entry point JS
│   │   ├── custom.js        # JS customizado
│   │   └── swiper.js        # Inicialização do Swiper
│   └── scss/
│       ├── style.scss       # SCSS principal
│       ├── _variables.scss  # Override de variáveis do Bootstrap
│       └── _utilities.scss  # Classes utilitárias customizadas
```

---

## Instalação e uso

### Pré-requisitos

- Node.js 18+
- npm

### Configuração

```bash
# 1. Clone o repositório
git clone 

# 2. Instale as dependências
npm install

# 3. Inicie o servidor de desenvolvimento
npm run dev
```

O servidor sobe em `http://localhost:3000` com hot reload automático.

---

## Build e deploy

```bash
npm run build
```

Os arquivos gerados ficam em `/dist`, organizados em:
- `assets/js/`
- `assets/css/`
- `assets/images/`

O projeto usa `base: './'` no Vite, então funciona em subdiretórios sem ajuste de paths.

---

## Customização

- **Cores e tipografia**: edite `src/assets/scss/_variables.scss` (override das variáveis do Bootstrap)
- **Utilitários**: `src/assets/scss/_utilities.scss`
- **JS customizado**: `src/assets/js/custom.js`

---

