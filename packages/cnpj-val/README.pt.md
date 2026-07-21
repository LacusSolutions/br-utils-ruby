![cnpj-val para Ruby](https://br-utils.vercel.app/img/cover_cnpj-val.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para validar CNPJ (Cadastro Nacional da Pessoa Jurídica).

## Recursos

- ✅ **CNPJ alfanumérico**: Valida CNPJ de 14 caracteres no formato numérico ou alfanumérico
- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings; elementos do array são concatenados na ordem
- ✅ **Agnóstico ao formato**: Remove caracteres não alfanuméricos (ou não numéricos quando `type` é `numeric`) e opcionalmente converte para maiúsculas antes de validar
- ✅ **Sensibilidade a maiúsculas opcional**: Com `case_sensitive` em `false`, letras minúsculas são aceitas para CNPJ alfanumérico
- ✅ **Sobrescrita por chamada**: Padrões da instância podem ser sobrescritos apenas naquela chamada a `is_valid`
- ✅ **Tratamento de erros**: Uso incorreto da API vs erros de domínio, com marcador `CnpjVal::Error` para rescue em toda a biblioteca
- ✅ **Dependências mínimas**: [`cnpj-dv`](https://rubygems.org/gems/cnpj-dv) para cálculo dos dígitos verificadores e [`lacus-utils`](https://rubygems.org/gems/lacus-utils) para descrição de tipos nas mensagens de erro
- ✅ **API dupla**: Orientada a objetos (`CnpjVal::CnpjValidator`) e funcional (`CnpjVal.cnpj_val`)

## Instalação

Instale a gem diretamente:

```bash
gem install cnpj-val
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cnpj-val'
```

## Require

```ruby
require 'cnpj-val'
```

## Início rápido

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new

validator.is_valid('98765432000198')       # => true
validator.is_valid('98.765.432/0001-98')   # => true
validator.is_valid('98765432000199')       # => false

validator.is_valid('1QB5UKALPYFP59')                         # => true (alfanumérico)
validator.is_valid('1QB5UKALpyfp59')                         # => false (padrão é case-sensitive)
validator.is_valid('1QB5UKALpyfp59', case_sensitive: false)  # => true

validator.is_valid('96206256120884')              # => true (numérico)
validator.is_valid('1QB5UKALPYFP59', type: 'numeric')   # => false (letras removidas → comprimento ≠ 14)
```

Helper funcional:

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val('98765432000198')      # => true
CnpjVal.cnpj_val('98.765.432/0001-98')  # => true
CnpjVal.cnpj_val('98765432000199')      # => false
```

## Utilização

Os pontos principais são a classe `CnpjVal::CnpjValidator`, a classe de opções `CnpjVal::CnpjValidatorOptions` e o helper `CnpjVal.cnpj_val`.

### `CnpjVal::CnpjValidator`

- **`initialize(options = nil, **keywords)`**: Opções padrão de validação. Quando `options` é fornecido isoladamente (instância de `CnpjVal::CnpjValidatorOptions` ou `Hash`), ele determina as opções padrão; uma instância de `CnpjVal::CnpjValidatorOptions` é armazenada por referência (mutações posteriores afetam futuras chamadas de `is_valid` que não passarem opções por chamada), enquanto um `Hash` cria uma nova instância. Quando `options` é omitido (`nil`), as opções padrão são construídas exclusivamente a partir dos argumentos nomeados (`case_sensitive:`, `type:`). Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`, em vez de ignorar os argumentos nomeados silenciosamente. Exemplo: `CnpjVal::CnpjValidator.new(type: 'numeric', case_sensitive: false)`.
- **`options`**: Retorna o `CnpjVal::CnpjValidatorOptions` da instância (o mesmo objeto usado internamente).
- **`is_valid(cnpj_input, options = nil, **keywords)`**: Valida um valor CNPJ.

  A entrada é normalizada para string (arrays de strings são concatenados). Quando `case_sensitive` é `false`, a string é convertida para maiúsculas antes da sanitização. Caracteres são removidos conforme `type`. Se o comprimento após sanitização não for exatamente **14**, se os dois últimos caracteres não forem dígitos ou se os dígitos verificadores não coincidirem (`CnpjDV::CnpjCheckDigits` de **`cnpj-dv`**), o método retorna `false` — nenhuma exceção é lançada por falha de validação.

  Se a entrada não for `String` nem `Array` de strings, é lançada **`CnpjVal::TypeMismatchError`**.

  `options` por chamada e argumentos nomeados nunca são mesclados: um `options` fornecido isoladamente sobrescreve totalmente os padrões da instância nesta chamada; caso contrário, qualquer argumento nomeado fornecido sobrescreve os padrões da instância nesta chamada. Quando nenhum dos dois é fornecido, os padrões da instância são usados como estão. Os padrões da instância nunca são alterados por uma sobrescrita pontual. Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`.

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new(type: 'numeric')

validator.is_valid('98.765.432/0001-98')   # => true
validator.is_valid('1QB5UKALPYFP59')       # => false (letras removidas → comprimento ≠ 14)
validator.is_valid('1QB5UKALpyfp59', type: 'alphanumeric', case_sensitive: false)  # => true
```

Padrões na instância; sobrescrita por chamada:

```ruby
require 'cnpj-val'

validator = CnpjVal::CnpjValidator.new(case_sensitive: false)

validator.is_valid('1qb5ukalpyfp59')                  # => true (padrões da instância)
validator.is_valid('1qb5ukalpyfp59', case_sensitive: true)  # só nesta chamada: false
validator.is_valid('1qb5ukalpyfp59')                  # => true de novo
```

### `CnpjVal::CnpjValidatorOptions`

Armazena configurações do validador (`case_sensitive`, `type`). Construa com um `Hash` opcional ou instância de `CnpjVal::CnpjValidatorOptions`, objetos extras de sobrescrita (mesclados em ordem) e/ou argumentos nomeados. Expõe acessores: `case_sensitive`, `type`.

- **`all`**: Retorna um snapshot superficial congelado (`Hash`) de todas as opções atuais.
- **`set(options)`**: Atualiza vários campos de uma vez; retorna `self`. Aceita um `Hash` ou outra instância de `CnpjVal::CnpjValidatorOptions`. Chaves omitidas mantêm o valor atual.

```ruby
require 'cnpj-val'

options = CnpjVal::CnpjValidatorOptions.new(case_sensitive: false, type: 'numeric')
options.case_sensitive   # => false
options.type             # => "numeric"
options.set({ type: 'alphanumeric' })  # mescla e retorna self
options.all              # => snapshot congelado das opções atuais
```

### Helper funcional

`CnpjVal.cnpj_val` instancia um novo `CnpjVal::CnpjValidator` com os mesmos parâmetros do construtor e chama `is_valid(cnpj_input)` uma vez. Passe argumentos nomeados **ou** um `Hash`/instância de `CnpjVal::CnpjValidatorOptions` para as opções — não ambos (passar ambos lança `InvalidArgumentCombinationError`):

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val('98765432000198')                              # => true
CnpjVal.cnpj_val('1QB5UKALpyfp59', case_sensitive: false)       # => true
CnpjVal.cnpj_val('1QB5UKALPYFP59', type: 'numeric')           # => false
CnpjVal.cnpj_val('1QB5UKALpyfp59', {                            # forma com Hash
  type: 'alphanumeric',
  case_sensitive: false,
})                                                              # => true
```

### Formatos de entrada

**String:** Dígitos e/ou letras brutos, ou CNPJ já formatado (ex.: `98.765.432/0001-98`, `1Q.B5U.KAL/PYFP-59`). Caracteres são removidos conforme `type`; quando `case_sensitive` é `false`, letras são convertidas para maiúsculas antes da validação alfanumérica.

**Array de strings:** Cada elemento deve ser `String`; os valores são concatenados (ex.: por dígito, segmentos agrupados ou misturados com pontuação). Elementos que não sejam string lançam **`CnpjVal::TypeMismatchError`**.

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val(['1', 'Q', 'B', '5', 'U', 'K', 'A', 'L', 'P', 'Y', 'F', 'P', '5', '9'])  # => true
CnpjVal.cnpj_val(['1Q.B5U', 'KAL', 'PYFP-59'])  # => true
```

### Opções de validação

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-------------|
| `type` | `'alphanumeric'` \| `'numeric'` \| `nil` | `'alphanumeric'` | Conjunto de caracteres após sanitização: alfanumérico (`0`–`9`, `A`–`Z`, `a`–`z`) ou apenas numérico (`0`–`9`) |
| `case_sensitive` | `Boolean`, `nil` | `true` | Se `false`, letras minúsculas são convertidas para maiúsculas antes da validação alfanumérica |

CNPJ inválido (comprimento errado após sanitização, dígitos verificadores inválidos, base/filial inelegíveis `00000000` / `0000`, dígitos repetidos, caracteres não numéricos nos verificadores) retorna **`false`** — nenhuma exceção é lançada por falha de validação.

Exemplo com todas as opções:

```ruby
require 'cnpj-val'

CnpjVal.cnpj_val(
  '1QB5UKALpyfp59',
  type: 'alphanumeric',
  case_sensitive: false,
)
```

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado para a entrada CNPJ ou para uma opção, ou combinação inválida de argumentos). |
| **Erro de domínio** | A forma da chamada era válida, mas um valor viola uma regra de negócio (`type` inválido). |

Todo erro customizado inclui o módulo marcador `CnpjVal::Error`. Falhas de domínio (`ValidationError`) herdam de `CnpjVal::DomainError` (`RangeError`). Dados de CNPJ inválidos retornam `false` (não levantam erro).

**Importante:** passar ao mesmo tempo uma instância/`Hash` de `options` e argumentos nomeados levanta `InvalidArgumentCombinationError`.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CnpjVal::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Entrada CNPJ ou opção com tipo de dado incorreto |
| `CnpjVal::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | Uso incorreto da API | Instância/`Hash` de `options` e argumentos nomeados passados ao mesmo tempo |
| `CnpjVal::ValidationError` | `CnpjVal::DomainError` | Erro de domínio | `type` fora dos valores permitidos |

#### `CnpjVal::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de rescue) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca levantado diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatá-lo:**

```ruby
rescue CnpjVal::Error
  # tudo o que esta biblioteca levanta
```

#### `CnpjVal::DomainError`

- **Herança:** `CnpjVal::DomainError < RangeError` (inclui `CnpjVal::Error`)
- **Categoria:** Erro de domínio — ancestral de todas as falhas de domínio.
- **Quando é levantado:** Não levantado diretamente; prefira levantar uma subclasse folha.
- **Exemplo:** Prefira `raise CnpjVal::ValidationError` a levantar `DomainError` diretamente.
- **Como resgatá-lo:**

```ruby
rescue CnpjVal::DomainError
  # ValidationError e outras subclasses de DomainError
```

#### `CnpjVal::TypeMismatchError`

- **Herança:** `CnpjVal::TypeMismatchError < TypeError` (inclui `CnpjVal::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada CNPJ não é `String` nem `Array` de strings, ou quando uma opção do validador (`type`) tem o tipo de runtime incorreto.
- **Exemplo:**

```ruby
CnpjVal.cnpj_val(12_345_678_000_198) # levanta CnpjVal::TypeMismatchError
CnpjVal.cnpj_val('98765432000198', type: 123) # levanta CnpjVal::TypeMismatchError
```

- **Como resgatá-lo:**

```ruby
rescue CnpjVal::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CnpjVal::InvalidArgumentCombinationError`

- **Herança:** `CnpjVal::InvalidArgumentCombinationError < ArgumentError` (inclui `CnpjVal::Error`)
- **Categoria:** Uso incorreto da API — os argumentos fornecidos não formam uma assinatura válida da API.
- **Quando é levantado:** Levantado quando `CnpjValidator.new`, `#is_valid` ou `cnpj_val` recebe ao mesmo tempo um argumento `options` (instância ou `Hash`) e qualquer argumento nomeado não `nil`.
- **Exemplo:**

```ruby
begin
  CnpjVal.cnpj_val('98765432000198', { type: 'numeric' }, case_sensitive: false)
rescue CnpjVal::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (case_sensitive:, type:), not both.
end
```

- **Como resgatá-lo:**

```ruby
rescue CnpjVal::InvalidArgumentCombinationError
  # combinação inválida de assinatura desta biblioteca

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta biblioteca
```

#### `CnpjVal::ValidationError`

- **Herança:** `CnpjVal::ValidationError < CnpjVal::DomainError < RangeError` (inclui `CnpjVal::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de comprimento.
- **Quando é levantado:** Levantado quando `type` não é `'alphanumeric'` nem `'numeric'`.
- **Exemplo:**

```ruby
CnpjVal.cnpj_val('98765432000198', type: 'invalid') # levanta CnpjVal::ValidationError
```

- **Como resgatá-lo:**

```ruby
rescue CnpjVal::ValidationError
  # esta falha exata de validação de domínio

rescue CnpjVal::DomainError
  # ValidationError e outras subclasses de DomainError
```

#### Granularidade de rescue

```ruby
# 1) Classe nativa única — captura erros de uso incorreto desse tipo.
rescue TypeError
  # CnpjVal::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CnpjVal::DomainError — captura todas as violações de regra de negócio sob DomainError.
rescue CnpjVal::DomainError
  # CnpjVal::ValidationError e outras subclasses de DomainError

# 3) CnpjVal::Error — captura tudo o que a biblioteca levanta.
rescue CnpjVal::Error
  # todo erro customizado que inclui CnpjVal::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CnpjVal::ValidationError
  # apenas CnpjVal::ValidationError
```

Atributos notáveis nos erros levantados:

- `TypeMismatchError`: `option_name` (nil para entrada CNPJ), `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `expected_values`

## API

### Exportações

Após `require 'cnpj-val'`:

- **`CnpjVal.cnpj_val`**: `(cnpj_input, options = nil, **keywords) -> Boolean` — helper de conveniência.
- **`CnpjVal::CnpjValidator`**: Classe para validar CNPJ com opções padrão opcionais; aceita `String` ou `Array<String>` em `is_valid`.
- **`CnpjVal::CnpjValidatorOptions`**: Classe que armazena opções; suporta mesclagem via construtor, `set` e argumentos nomeados.
- **`CnpjVal::CNPJ_LENGTH`**: `14` (constante).
- **`CnpjVal::VERSION`**: string de versão da gem.
- **Marcadores de tipo**: `CnpjVal::CnpjInput`, `CnpjVal::CnpjType`, `CnpjVal::CnpjValidatorOptionsInput`.
- **Erros**: `CnpjVal::Error`, `CnpjVal::DomainError`, `CnpjVal::TypeMismatchError`, `CnpjVal::InvalidArgumentCombinationError`, `CnpjVal::ValidationError`.

### Outros recursos disponíveis

- **`CnpjVal::CnpjValidatorOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjVal::CnpjValidatorOptions::DEFAULT_CASE_SENSITIVE`**: `true`.
- **`CnpjVal::CnpjValidatorOptions::DEFAULT_TYPE`**: `'alphanumeric'`.

## Contribuição e suporte

Contribuições são bem-vindas! Consulte as [Diretrizes de contribuição](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md). Se este projeto for útil para você, considere:

- ⭐ Dar uma estrela ao repositório
- 🤝 Contribuir com o código
- 💡 [Sugerir novos recursos](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reportar bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## Licença

Este projeto está licenciado sob a MIT License — consulte o arquivo [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE).

## Changelog

Consulte o [CHANGELOG](./CHANGELOG.md) para histórico de versões e alterações.

---

Feito com ❤️ por [Lacus Solutions](https://github.com/LacusSolutions)
