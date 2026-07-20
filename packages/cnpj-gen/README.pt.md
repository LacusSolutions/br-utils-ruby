![cnpj-gen para Ruby](https://br-utils.vercel.app/img/cover_cnpj-gen.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para gerar CNPJs válidos (Cadastro Nacional da Pessoa Jurídica).

## Recursos

- ✅ **CNPJ alfanumérico**: Gera CNPJ de 14 caracteres com conjuntos opcionais numérico, alfabético ou alfanumérico (padrão)
- ✅ **Prefixo opcional**: Informe de 0 a 12 caracteres alfanuméricos para fixar o início do CNPJ (ex.: base) e gerar o restante com dígitos verificadores válidos
- ✅ **Formatação**: Opção de retornar a string no formato padrão (`00.000.000/0000-00`)
- ✅ **Gerador reutilizável**: Classe `CnpjGen::CnpjGenerator` com opções padrão e sobrescritas por chamada
- ✅ **Sobrescritas por palavra-chave**: Passe `format:`, `prefix:` e `type:` em `cnpj_gen`, `CnpjGenerator#generate` e nos construtores
- ✅ **Dependências mínimas**: Apenas [`cnpj-dv`](https://rubygems.org/gems/cnpj-dv) e [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Uso incorreto da API vs erros de domínio, com marcador `CnpjGen::Error` para captura em toda a biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cnpj-gen
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cnpj-gen'
```

## Require

```ruby
require 'cnpj-gen'
```

## Início rápido

```ruby
require 'cnpj-gen'

CnpjGen.cnpj_gen                    # => ex.: "AB123CDE000155" (14 caracteres alfanuméricos)

CnpjGen.cnpj_gen(format: true)      # => ex.: "AB.123.CDE/0001-55"

CnpjGen.cnpj_gen(prefix: '45623767')           # => ex.: "45623767ABCD96"
CnpjGen.cnpj_gen(                              # => ex.: "45.623.767/ABCD-96"
  prefix: '45623767',
  format: true
)

CnpjGen.cnpj_gen(type: 'numeric')      # => ex.: "65453043000178" (apenas dígitos)
CnpjGen.cnpj_gen(type: 'alphabetic')   # => ex.: "ABCDEFGHIJKL80" (apenas letras, exceto dígitos verificadores)
```

As opções também podem ser passadas como `Hash`:

```ruby
CnpjGen.cnpj_gen({ format: true, type: 'numeric' })
```

## Utilização

Os pontos principais são o helper de módulo `CnpjGen.cnpj_gen`, a classe `CnpjGen::CnpjGenerator` e a classe de opções `CnpjGen::CnpjGeneratorOptions`.

### Opções do gerador

Todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se truthy, retorna o CNPJ gerado no formato padrão (`00.000.000/0000-00`). Valores não booleanos são convertidos (`false`, `''` e `0` viram `false`; demais valores viram truthy). |
| `prefix` | `String` | `''` | String inicial parcial (0–12 caracteres alfanuméricos). Apenas alfanuméricos são mantidos e convertidos para maiúsculas; os caracteres faltantes são gerados aleatoriamente e os dígitos verificadores são calculados. |
| `type` | `String` | `'alphanumeric'` | Conjunto de caracteres da parte gerada aleatoriamente (o `prefix` é mantido após sanitização). Deve ser um de `'numeric'`, `'alphabetic'` ou `'alphanumeric'`. **Os dígitos verificadores são sempre numéricos.** |

Regras do prefixo: a base (primeiros 8 caracteres) e a filial (caracteres 9–12) não podem ser todos zeros; 12 dígitos repetidos (ex.: `777777777777`) também não são permitidos.

`nil` é aceito como argumento nomeado em `cnpj_gen`, `CnpjGenerator.new`, `CnpjGenerator#generate` e `CnpjGeneratorOptions.new`/`#set` — significa apenas "sem sobrescrita para esta opção". **Não** é aceito pelos setters de propriedade de `CnpjGeneratorOptions` (`options.format = valor`, `options.prefix = valor`, `options.type = valor`): chamar um setter com `nil` diretamente lança `CnpjGen::TypeMismatchError`. Para redefinir uma propriedade ao seu valor padrão via setter, passe a constante literal, ex.: `options.format = CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT`.

### `CnpjGen.cnpj_gen` (helper)

Gera uma string de CNPJ válida. Sem opções, retorna um CNPJ alfanumérico de 14 caracteres. É um atalho para `CnpjGen::CnpjGenerator.new(...).generate`.

- **`options`** (opcional): instância de `CnpjGen::CnpjGeneratorOptions`, `Hash` de chaves de opção ou `nil`. Veja [Opções do gerador](#opções-do-gerador).
- **`format`**, **`prefix`**, **`type`** (argumentos nomeados): Usados apenas quando `options` é omitido (`nil`). Passar `options` **e** qualquer um desses argumentos nomeados ao mesmo tempo gera `InvalidArgumentCombinationError` — as duas formas de passar opções nunca são mescladas entre si.

### `CnpjGen::CnpjGenerator` (classe)

Para padrões reutilizáveis ou sobrescritas por chamada, use a classe:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(type: 'numeric', format: true)

generator.generate                    # => ex.: "73.008.535/0005-06"
generator.generate(prefix: '12345678')   # sobrescrita apenas nesta chamada
generator.options                     # opções padrão atuais (CnpjGen::CnpjGeneratorOptions)
```

- **`initialize(options = nil, **keywords)`**: Opções padrão opcionais. Quando `options` é fornecido isoladamente (instância de `CnpjGen::CnpjGeneratorOptions` ou `Hash`), ele determina as opções padrão; uma instância de `CnpjGen::CnpjGeneratorOptions` é armazenada por referência (mutações posteriores afetam futuras chamadas de `generate` que não passarem opções por chamada), enquanto um `Hash` cria uma nova instância. Quando `options` é omitido (`nil`), as opções padrão são construídas exclusivamente a partir dos argumentos nomeados (`format:`, `prefix:`, `type:`). Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`, em vez de ignorar os argumentos nomeados silenciosamente.
- **`generate(options = nil, **keywords)`**: Retorna um CNPJ válido. `options` e os argumentos nomeados nunca são mesclados: um `options` fornecido isoladamente sobrescreve totalmente os padrões da instância nesta chamada; caso contrário, qualquer argumento nomeado fornecido sobrescreve os padrões da instância nesta chamada. Quando nenhum dos dois é fornecido, os padrões da instância são usados como estão. Os padrões da instância nunca são alterados por uma sobrescrita pontual. Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`.
- **`options`**: Reader que retorna as opções padrão usadas quando não há opções por chamada (mesma instância usada internamente; mutá-la afeta futuras chamadas de `generate`).

Opções padrão na instância; sobrescritas por chamada:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(format: true)

generator.generate              # CNPJ formatado
generator.generate(format: false)  # somente nesta chamada: sem formato
generator.generate              # volta ao padrão da instância
```

### `CnpjGen::CnpjGeneratorOptions` (classe)

Armazena opções (`format`, `prefix`, `type`) com validação e suporte a mesclagem:

```ruby
require 'cnpj-gen'

options = CnpjGen::CnpjGeneratorOptions.new(
  prefix: 'AB123XYZ',
  type: 'numeric',
  format: true
)
options.prefix   # => "AB123XYZ"
options.type     # => "numeric"
options.format   # => true
options.set(format: false)  # mescla e retorna self
options.all      # => { format: false, prefix: "AB123XYZ", type: "numeric" }

# Redefinir uma propriedade ao seu valor padrão exige a constante literal —
# um `nil` direto no setter lança TypeMismatchError:
options.format = CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT
```

- **`initialize(*options, **keywords)`**: Cada argumento posicional `options` (um `Hash` ou outra instância de `CnpjGen::CnpjGeneratorOptions`) é combinado da esquerda para a direita — os últimos prevalecem — e então os argumentos nomeados (`format:`, `prefix:`, `type:`) são aplicados por cima com a maior precedência. Em cada etapa, um valor `nil` para uma dada chave é ignorado em favor do que já foi resolvido. Qualquer opção ainda não resolvida recebe seu valor `DEFAULT_*`.
- **`format`**, **`prefix`**, **`type`**: Acessores com setters; `prefix` é validado (base/filial inelegíveis, dígitos repetidos). Os setters **nunca aceitam `nil`** — passe a constante `DEFAULT_*` correspondente (ex.: `CnpjGeneratorOptions::DEFAULT_PREFIX`) para redefinir uma propriedade explicitamente.
- **`set(*options, **keywords)`**: Atualiza várias opções de uma vez, usando a mesma resolução de `initialize` (combinação seguida de argumentos nomeados, ignorando `nil`). Qualquer opção não resolvida após a combinação mantém seu valor **atual** na instância (uma atualização parcial, não uma reinicialização). Retorna `self`.
- **`all`**: Cópia superficial em `Hash` das opções atuais (`:format`, `:prefix`, `:type`).

## API

### Exportações

Após `require 'cnpj-gen'`:

- **`CnpjGen.cnpj_gen`**: `(options = nil, **keywords) -> String` — helper de conveniência.
- **`CnpjGen::CnpjGenerator`**: Classe para gerar CNPJ com opções padrão e sobrescritas por chamada.
- **`CnpjGen::CnpjGeneratorOptions`**: Classe que armazena opções com validação e mesclagem.
- **`CnpjGen::CNPJ_LENGTH`**: `14` (constante).
- **`CnpjGen::CNPJ_PREFIX_MAX_LENGTH`**: `12` (constante).
- **`CnpjGen::CNPJ_TYPE_VALUES`**: `%w[alphabetic alphanumeric numeric]` — valores permitidos para `type`.
- **`CnpjGen::VERSION`**: string da versão da gem.
- **Erros**: `CnpjGen::Error`, `CnpjGen::DomainError`, `CnpjGen::TypeMismatchError`, `CnpjGen::InvalidArgumentCombinationError`, `CnpjGen::ValidationError`.

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado para uma opção, ou combinação inválida de argumentos). |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (`prefix` inválido, ou `type` fora do conjunto permitido). |

Todo erro customizado inclui o módulo marcador `CnpjGen::Error`. Falhas de domínio (`ValidationError`) herdam de `CnpjGen::DomainError` (`RangeError`).

**Importante:** passar ao mesmo tempo uma instância/`Hash` de `options` e argumentos nomeados levanta `InvalidArgumentCombinationError`.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CnpjGen::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | Uso incorreto da API | Instância/`Hash` de `options` e argumentos nomeados passados ao mesmo tempo |
| `CnpjGen::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Uma opção do gerador tem o tipo de dado incorreto |
| `CnpjGen::ValidationError` | `CnpjGen::DomainError` | Erro de domínio | `prefix` inelegível, ou `type` fora dos valores permitidos |

#### `CnpjGen::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CnpjGen::Error
  # tudo o que esta biblioteca levanta
```

#### `CnpjGen::DomainError`

- **Herança:** `CnpjGen::DomainError < RangeError` (inclui `CnpjGen::Error`)
- **Categoria:** Erro de domínio — ancestral de todas as falhas de domínio.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CnpjGen::ValidationError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CnpjGen::DomainError
  # ValidationError e outras subclasses de DomainError
```

#### `CnpjGen::TypeMismatchError`

- **Herança:** `CnpjGen::TypeMismatchError < TypeError` (inclui `CnpjGen::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando uma opção do gerador (`format`, `prefix` ou `type`) tem o tipo de runtime incorreto.
- **Exemplo:**

```ruby
CnpjGen.cnpj_gen(prefix: 123) # levanta CnpjGen::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CnpjGen::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CnpjGen::InvalidArgumentCombinationError`

- **Herança:** `CnpjGen::InvalidArgumentCombinationError < ArgumentError` (inclui `CnpjGen::Error`)
- **Categoria:** Uso incorreto da API — o chamador misturou padrões de argumentos mutuamente exclusivos.
- **Quando é levantado:** Levantado quando `CnpjGenerator.new`, `#generate` ou `cnpj_gen` recebe ao mesmo tempo um argumento `options` (instância ou `Hash`) e qualquer argumento nomeado não-`nil`.
- **Exemplo:**

```ruby
begin
  CnpjGen::CnpjGenerator.new({ format: true }, prefix: 'AB')
rescue CnpjGen::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (format:, prefix:, type:), not both.
end
```

- **Como resgatar:**

```ruby
rescue CnpjGen::InvalidArgumentCombinationError
  # combinação inválida de argumentos desta biblioteca

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta biblioteca
```

#### `CnpjGen::ValidationError`

- **Herança:** `CnpjGen::ValidationError < CnpjGen::DomainError < RangeError` (inclui `CnpjGen::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando `prefix` é inelegível (base/filial zerada, ou 12 dígitos repetidos), ou quando `type` não é um de `'alphabetic'`, `'alphanumeric'` ou `'numeric'`.
- **Exemplo:**

```ruby
CnpjGen.cnpj_gen(prefix: '000000000001') # levanta CnpjGen::ValidationError
CnpjGen.cnpj_gen(type: 'invalid')        # levanta CnpjGen::ValidationError
```

- **Como resgatar:**

```ruby
rescue CnpjGen::ValidationError
  # esta falha exata de validação de domínio

rescue CnpjGen::DomainError
  # falhas de domínio com raiz em RangeError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Classe nativa — captura uso incorreto de tipo desta biblioteca (e outros TypeErrors).
rescue TypeError
  # CnpjGen::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CnpjGen::DomainError — captura violações de regra de negócio sob DomainError.
rescue CnpjGen::DomainError
  # CnpjGen::ValidationError e outras subclasses de DomainError

# 3) CnpjGen::Error — captura tudo o que a biblioteca levanta.
rescue CnpjGen::Error
  # todo erro customizado que inclui CnpjGen::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CnpjGen::ValidationError
  # apenas CnpjGen::ValidationError
```

Atributos relevantes:

- `TypeMismatchError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `reason` (falhas de prefixo), `expected_values` (falhas de type)

Os setters de propriedade nunca aceitam `nil` diretamente — passe a constante `DEFAULT_*` correspondente para redefinir:

```ruby
options = CnpjGen::CnpjGeneratorOptions.new
begin
  options.prefix = nil
rescue CnpjGen::TypeMismatchError => e
  puts e.message
  # CNPJ generator option "prefix" must be of type string. Got nil.
end

options.prefix = CnpjGen::CnpjGeneratorOptions::DEFAULT_PREFIX # redefinição explícita
```

Falhas de cálculo de dígitos verificadores pelo `cnpj-dv` são tratadas internamente com nova tentativa de geração usando as mesmas opções resolvidas; em operação normal não são propagadas ao chamador.

### Outros recursos disponíveis

- **`CnpjGen::CnpjGeneratorOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjGen::CnpjGeneratorOptions::CNPJ_PREFIX_MAX_LENGTH`**: `12`.
- **`CnpjGen::CnpjGeneratorOptions::DEFAULT_FORMAT`**, **`DEFAULT_PREFIX`**, **`DEFAULT_TYPE`**: Constantes de padrão no nível da classe.

## Contribuição e suporte

Contribuições são bem-vindas! Consulte as [Diretrizes de contribuição](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md). Se este projeto for útil para você, considere:

- ⭐ Dar uma estrela no repositório
- 🤝 Contribuir com o código
- 💡 [Sugerir novos recursos](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reportar bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## Licença

Este projeto está licenciado sob a MIT License — consulte o arquivo [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE).

## Changelog

Veja o [CHANGELOG](./CHANGELOG.md) para histórico de versões e alterações.

---

Feito com ❤️ por [Lacus Solutions](https://github.com/LacusSolutions)
