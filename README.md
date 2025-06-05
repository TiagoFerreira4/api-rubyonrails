# DigitalLibraryApi

Esta é a API backend do projeto **DigitalLibraryApi**, construída em Ruby on Rails. A API fornece rotas para gerenciar **usuários**, **autores** e **materiais** (livros, artigos e vídeos), além de suporte a autenticação via JWT (Devise + devise-jwt).

O objetivo deste README é documentar:

1.  **Como configurar e executar a API localmente**
2.  **Rotas disponíveis**
3.  **Autenticação (login, logout e uso de token JWT)**
4.  **Exemplos de requisições (cURL)**

---

## 1. Instalação e Configuração

### Requisitos

- Ruby 3.2 ou superior
- PostgreSQL (versão 12+ recomendada)
- Node.js e Yarn (para compilar assets, caso utilize front-end integrado)
- Bundler (gem `bundler`)

### Passos

1.  **Clone o repositório**

    ```bash
    git clone https://<seu-repositorio>/DigitalLibraryApi.git
    cd DigitalLibraryApi
    ```

2.  **Instale as gems**

    ```bash
    bundle install
    ```

3.  **Configure variáveis de ambiente**
    Crie um arquivo `.env` na raiz do projeto (este arquivo não deve ser versionado) com as seguintes variáveis mínimas (ajuste conforme necessário):

    ```dotenv
    # .env
    RAILS_ENV=development

    # Configuração do PostgreSQL
    DB_USERNAME=seu_usuario
    DB_PASSWORD=sua_senha
    DB_HOST=localhost
    DB_PORT=5432
    DB_NAME=digital_library_api_development

    # Chave secreta para JWT (pode ser gerada com `rails secret`)
    DEVISE_JWT_SECRET_KEY=<sua_chave_secreta_jwt>
    ```

4.  **Crie e migre o banco de dados**

    ```bash
    rails db:create
    rails db:migrate
    ```

5.  **(Opcional) Popule dados iniciais (seed)**
    Se existir um arquivo `db/seeds.rb` com dados de exemplo, execute:

    ```bash
    rails db:seed
    ```

6.  **Execute o servidor Rails**
    ```bash
    rails server
    ```
    Por padrão, o servidor estará disponível em `http://localhost:3000`.

## 2. Autenticação

A API utiliza Devise + devise-jwt para autenticar usuários via JSON Web Token (JWT). Os fluxos disponíveis são:

- Cadastro (`sign up`)
- Login (`sign in`)
- Logout (`sign out`)

### 2.1 Cadastro de Usuário (Sign Up)

- **Endpoint**: `POST /api/v1/signup`
- **Cabeçalho**: `Content-Type: application/json`
- **Corpo (JSON)**:
  ```json
  {
    "user": {
      "email": "usuario@dominio.com",
      "password": "senha_segura",
      "password_confirmation": "senha_segura"
    }
  }
  ```
- **Resposta de Sucesso (201 Created)**:
  ```json
  {
    "message": "User created successfully. Please login."
  }
  ```
- **Resposta de Erro (422 Unprocessable Entity)**:
  ```json
  {
    "errors": [
      "Email has already been taken",
      "Password is too short (minimum is 6 characters)"
    ]
  }
  ```

### 2.2 Login (Sign In)

- **Endpoint**: `POST /api/v1/login`
- **Cabeçalho**: `Content-Type: application/json`
- **Corpo (JSON)**:
  ```json
  {
    "user": {
      "email": "usuario@dominio.com",
      "password": "senha_segura"
    }
  }
  ```
- **Resposta de Sucesso (200 OK)**:
  O cabeçalho da resposta incluirá o token JWT em `Authorization: Bearer <token_jwt>`.
  O corpo JSON contém dados básicos do usuário:
  ```json
  {
    "data": {
      "id": 1,
      "type": "user",
      "attributes": {
        "email": "usuario@dominio.com",
        "created_at": "2025-06-05T14:00:00.000Z",
        "updated_at": "2025-06-05T14:00:00.000Z"
      }
    }
  }
  ```
- **Resposta de Erro (401 Unauthorized)**:
  ```json
  {
    "errors": ["Invalid Email or password."]
  }
  ```

### 2.3 Logout (Sign Out)

- **Endpoint**: `DELETE /api/v1/logout`
- **Cabeçalho**: `Authorization: Bearer <token_jwt_atual>`
- **Resposta de Sucesso (200 OK)**:
  ```json
  {
    "message": "Logged out successfully."
  }
  ```
  Isso revoga o JWT, impedindo seu uso subsequente.

## 3. Rotas da API REST (v1)

As rotas estão agrupadas sob `/api/v1`. Todas retornam JSON por padrão.

### 3.1. Autores (Authors) – Acesso Público

#### Listar Autores

- **Método**: `GET`
- **URL**: `/api/v1/authors`
- **Query Parameters Opcionais**:
  - `page` (inteiro) – número da página (padrão: 1)
  - `per_page` (inteiro) – itens por página (padrão: 10)
- **Exemplo (cURL)**:
  ```bash
  curl -X GET "http://localhost:3000/api/v1/authors?page=1&per_page=5" \
       -H "Accept: application/json"
  ```
- **Resposta (200 OK)**:
  ```json
  {
    "authors": [
      {
        "id": 1,
        "type": "author",
        "attributes": {
          "name": "Fyodor Dostoyevsky",
          "date_of_birth": "1821-11-11",
          "date_of_death": "1881-02-09"
        }
      },
      {
        "id": 2,
        "type": "author",
        "attributes": {
          "name": "J. K. Rowling",
          "date_of_birth": "1965-07-31",
          "date_of_death": null
        }
      }
    ],
    "meta": {
      "current_page": 1,
      "next_page": 2,
      "prev_page": null,
      "total_pages": 10,
      "total_count": 50
    }
  }
  ```

#### Visualizar um Autor

- **Método**: `GET`
- **URL**: `/api/v1/authors/:id`
- **Exemplo (cURL)**:
  ```bash
  curl -X GET "http://localhost:3000/api/v1/authors/1" \
       -H "Accept: application/json"
  ```
- **Resposta (200 OK)**:
  ```json
  {
    "author": {
      "id": 1,
      "type": "author",
      "attributes": {
        "name": "Fyodor Dostoyevsky",
        "date_of_birth": "1821-11-11",
        "date_of_death": "1881-02-09"
      }
    }
  }
  ```

### 3.2. Materiais (Materials) – Acesso Protegido (exceto `show`)

#### Listar Materiais

- **Método**: `GET`
- **URL**: `/api/v1/materials`
- **Cabeçalhos**: `Authorization: Bearer <token_jwt>`, `Accept: application/json`
- **Query Parameters Opcionais**:
  - `page` (inteiro) – padrão: 1
  - `per_page` (inteiro) – padrão: 10
  - `term` (string) – termo de busca para filtrar por `title` ou `author.name`.
- **Exemplo (cURL)**:
  ```bash
  curl -X GET "http://localhost:3000/api/v1/materials?term=Rowling" \
       -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
       -H "Accept: application/json"
  ```
- **Resposta (200 OK)**:
  ```json
  {
    "materials": [
      {
        "id": 11,
        "type": "book",
        "attributes": {
          "title": "Harry Potter and the Sorcerer's Stone",
          "description": "A young wizard's journey...",
          "status": "rascunho",
          "author": { "id": 3, "name": "J. K. Rowling" },
          "type": "Book",
          "isbn": "9780590353427",
          "number_of_pages": 320,
          "created_at": "2025-06-05T14:30:00.000Z",
          "updated_at": "2025-06-05T14:30:00.000Z"
        }
      }
    ],
    "meta": {
      "current_page": 1,
      "next_page": 2,
      "prev_page": null,
      "total_pages": 3,
      "total_count": 22
    }
  }
  ```

#### Visualizar um Material (Acesso Público)

- **Método**: `GET`
- **URL**: `/api/v1/materials/:id`
- **Cabeçalho**: `Accept: application/json`
- **Exemplo (cURL)**:
  ```bash
  curl -X GET "http://localhost:3000/api/v1/materials/8" \
       -H "Accept: application/json"
  ```
- **Resposta (200 OK)**:
  ```json
  {
    "material": {
      "id": 8,
      "type": "book",
      "attributes": {
        "title": "Crime and punishment",
        "description": "Um romance clássico...",
        "status": "rascunho",
        "author": { "id": 5, "name": "Fyodor Dostoyevsky" },
        "type": "Book",
        "isbn": "9780140449136",
        "number_of_pages": 671,
        "created_at": "2025-06-05T14:00:00.000Z",
        "updated_at": "2025-06-05T14:00:00.000Z"
      }
    }
  }
  ```

#### Criar um Material

- **Método**: `POST`
- **URL**: `/api/v1/materials`
- **Cabeçalhos**: `Authorization: Bearer <token_jwt>`, `Content-Type: application/json`
- **Corpo (JSON)**:

  - **Campos Comuns**: `type` ("Book", "Article", "Video"), `title`, `description`, `status`, `author_id`.
  - **Campos Específicos**:
    - **Book**: `isbn`, `number_of_pages`.
    - **Article**: `doi`.
    - **Video**: `duration_minutes`.

- **Exemplo 1: Criar Livro com ISBN (busca automática de dados)**

  ```bash
  curl -X POST "http://localhost:3000/api/v1/materials" \
       -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
       -H "Content-Type: application/json" \
       -d '{
         "material": {
           "type": "Book",
           "description": "Um clássico russo",
           "status": "rascunho",
           "isbn": "9780140449136"
         }
       }'
  ```

- **Exemplo 2: Criar Livro Manualmente**

  ```bash
  curl -X POST "http://localhost:3000/api/v1/materials" \
       -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
       -H "Content-Type: application/json" \
       -d '{
         "material": {
           "type": "Book",
           "title": "Meu Livro Manual",
           "description": "Descrição do meu livro.",
           "status": "rascunho",
           "author_id": 3,
           "number_of_pages": 250
         }
       }'
  ```

- **Resposta de Sucesso (201 Created)**:

  ```json
  {
    "material": {
      "id": 8,
      "type": "book",
      "attributes": {
        "title": "Crime and punishment",
        "description": "Um clássico russo",
        "status": "rascunho",
        "author": { "id": 5, "name": "Фёдор Михайлович Достоевский" },
        "type": "Book",
        "isbn": "9780140449136",
        "number_of_pages": 671,
        "created_at": "2025-06-05T14:00:00.000Z",
        "updated_at": "2025-06-05T14:00:00.000Z"
      }
    }
  }
  ```

- **Resposta de Erro (422 Unprocessable Entity)**:
  ```json
  {
    "errors": ["Title can't be blank", "Status can't be blank"]
  }
  ```

#### Atualizar um Material

- **Método**: `PATCH`
- **URL**: `/api/v1/materials/:id`
- **Cabeçalhos**: `Authorization: Bearer <token_jwt>`, `Content-Type: application/json`
- **Corpo (JSON)**: Envie apenas os campos a serem alterados.
- **Exemplo (cURL)**:
  ```bash
  curl -X PATCH "http://localhost:3000/api/v1/materials/8" \
       -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
       -H "Content-Type: application/json" \
       -d '{
         "material": {
           "status": "publicado"
         }
       }'
  ```
- **Resposta de Sucesso (200 OK)**: Retorna o JSON do material atualizado.
- **Resposta de Erro (422 Unprocessable Entity)**:
  ```json
  {
    "errors": ["Status is not included in the list"]
  }
  ```

#### Excluir um Material

- **Método**: `DELETE`
- **URL**: `/api/v1/materials/:id`
- **Cabeçalho**: `Authorization: Bearer <token_jwt>`
- **Exemplo (cURL)**:
  ```bash
  curl -X DELETE "http://localhost:3000/api/v1/materials/8" \
       -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  ```
- **Resposta de Sucesso**: `204 No Content` (sem corpo de resposta).

## 5. Exemplo de Fluxo Completo (cURL)

### 5.1. Sign Up

```bash
curl -X POST "http://localhost:3000/api/v1/signup" \
     -H "Content-Type: application/json" \
     -d '{
       "user": {
         "email": "teste@example.com",
         "password": "senha123",
         "password_confirmation": "senha123"
       }
     }'

```

### 5.2 Login

```bash
curl -i -X POST "http://localhost:3000/api/v1/login" \
     -H "Content-Type: application/json" \
     -d '{
       "user": {
         "email": "teste@example.com",
         "password": "senha123"
       }
     }
```

Copie o token JWT do cabeçalho Authorization: Bearer <token_jwt>.

### Criar material (com Token)

```bash
curl -X POST "http://localhost:3000/api/v1/materials" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "material": {
         "type": "Book",
         "description": "Romance russo",
         "status": "rascunho",
         "isbn": "9780140449136"
       }
     }'
```

### Listar Materiais (com Token)

```bash
curl -X GET "http://localhost:3000/api/v1/materials" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/json"
```
