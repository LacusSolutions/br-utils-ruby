![cnpj-fmt para Ruby](https://br-utils.vercel.app/img/cover_cnpj-fmt.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para formatar CNPJ (Cadastro Nacional da Pessoa Jurídica) como valor alfanumérico de 14 caracteres, com opções de máscara, escape HTML e codificação para URL.

## Recursos

- ✅ **CNPJ alfanumérico**: Suporte a CNPJ de 14 caracteres alfanuméricos (dígitos e letras, ex.: `RK0CMT3W000100`)
- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings; elementos do array são concatenados na ordem
- ✅ **Agnóstico ao formato**: Remove caracteres não alfanuméricos e converte letras para maiúsculas antes de formatar
- ✅ **Delimitadores personalizáveis**: `dot_key`, `slash_key` e `dash_key` podem ser vazios ou strings de um ou vários caracteres
- ✅ **Mascaramento**: Ocultação opcional de um intervalo de índices com string de substituição configurável (`hidden`, `hidden_key`, `hidden_start`, `hidden_end`)
- ✅ **Saída HTML e URL**: `escape` opcional (entidades HTML) e `encode` opcional (codificação tipo componente de URI, semelhante ao `encodeURIComponent` do JavaScript)
- ✅ **Erro de tamanho sem exceção**: Comprimento inválido após sanitização é tratado via `on_fail` (o padrão retorna string vazia)
- ✅ **Dependências mínimas**: Apenas [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Erros de uso da API vs erros de domínio, com o marcador `CnpjFmt::Error` para resgate em nível de biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cnpj-fmt
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cnpj-fmt'
```

## Require

```ruby
require 'cnpj-fmt'
```

## Início rápido

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new

formatter.format('03603568000195')   # => "03.603.568/0001-95"
formatter.format('12ABC34500DE99')   # => "12.ABC.345/00DE-99"
formatter.format('RK0CMT3W000100')   # => "RK.0CM.T3W/0001-00"
```

Uso básico com o helper:

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(cnpj)                    # => "03.603.568/0001-95"
CnpjFmt.cnpj_fmt(cnpj, hidden: true)      # => "03.603.***/****-**"
CnpjFmt.cnpj_fmt(                         # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)
```

## Utilização

Os pontos principais são a classe `CnpjFmt::CnpjFormatter`, a classe de opções `CnpjFmt::CnpjFormatterOptions` e o helper `CnpjFmt.cnpj_fmt`.

### `CnpjFmt::CnpjFormatter`

- **`initialize`**: Opções padrão de formatação. O primeiro parâmetro pode ser `nil`, um `Hash` de chaves de opção ou uma instância de `CnpjFmt::CnpjFormatterOptions` (essa instância é armazenada; alterações posteriores afetam chamadas a `format` que não passarem opções por chamada). Também é possível passar campos como argumentos nomeados (`hidden:`, `hidden_key:`, `dot_key:`, …). Exemplo: `CnpjFmt::CnpjFormatter.new(hidden: true, slash_key: '|')`.
- **`options`**: Retorna o `CnpjFmt::CnpjFormatterOptions` da instância (o mesmo objeto usado internamente).
- **`format(cnpj_input, options = nil, **keywords)`**: Formata um valor CNPJ.

  A entrada é normalizada removendo caracteres não alfanuméricos e convertendo para maiúsculas. Se o comprimento após sanitização não for exatamente **14**, o callback **`on_fail`** é chamado com a entrada original e um `CnpjFmt::InvalidLengthError`; o valor de retorno do callback é o resultado (nada é lançado por comprimento).

  Se a entrada não for `String` nem `Array` de strings, é lançado **`CnpjFmt::TypeMismatchError`**.

  As opções por chamada são mescladas sobre os padrões da instância apenas naquela chamada (os padrões da instância não mudam). É possível passar uma instância de `CnpjFmt::CnpjFormatterOptions` ou um `Hash` como segundo argumento, além de argumentos nomeados; quando ambos forem fornecidos, o argumento `options` prevalece.

### `CnpjFmt::CnpjFormatterOptions`

Armazena todas as configurações do formatador, com validação e suporte a mesclagem. Expõe propriedades: `hidden`, `hidden_key`, `hidden_start`, `hidden_end`, `dot_key`, `slash_key`, `dash_key`, `escape`, `encode`, `on_fail`.

- **`initialize(options = nil, *extra_overrides, **keywords)`**: Opções padrão opcionais (`Hash` simples, instância de `CnpjFmt::CnpjFormatterOptions` ou argumentos nomeados), além de objetos extras de sobrescrita mesclados em ordem (as últimas sobrescritas prevalecem).
- **`all`**: Retorna uma cópia superficial em `Hash` de todas as opções atuais.
- **`copy`**: Retorna uma cópia superficial desta instância de opções.
- **`set(options)`**: Atualiza vários campos de uma vez; retorna `self`. Aceita um `Hash` ou outra instância de `CnpjFmt::CnpjFormatterOptions`. Valores `nil` explícitos na atualização mantêm o valor atual.
- **`set_hidden_range(hidden_start, hidden_end)`**: Valida índices em **`[0, 13]`** (inclusivos); se `hidden_start > hidden_end`, os valores são trocados. Argumentos `nil` usam os padrões (`DEFAULT_HIDDEN_START` / `DEFAULT_HIDDEN_END`).

**`hidden_start` / `hidden_end`**: Os índices referem-se à **string CNPJ normalizada de 14 caracteres** (antes de inserir pontuação). O intervalo inclusivo é substituído internamente por placeholders e depois por `hidden_key` (permite chaves com vários caracteres ou string vazia).

**Opções de chave** (`hidden_key`, `dot_key`, `slash_key`, `dash_key`): Devem ser strings e não podem conter caracteres em `CnpjFmt::CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS` (reservados para a lógica interna).

### Helper funcional

`CnpjFmt.cnpj_fmt` instancia um novo `CnpjFmt::CnpjFormatter` com os mesmos parâmetros do construtor e chama `format(cnpj_input)` uma vez. Use argumentos nomeados, um `Hash` ou uma instância de `CnpjFmt::CnpjFormatterOptions` para as opções:

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(cnpj)                # => "03.603.568/0001-95"
CnpjFmt.cnpj_fmt(cnpj, hidden: true)   # mascarado com padrões
CnpjFmt.cnpj_fmt(                     # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)
CnpjFmt.cnpj_fmt(cnpj, {              # forma com Hash
  hidden: true,
  hidden_key: '#'
})
```

### Exemplos orientados a objeto

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new
cnpj = '03603568000195'

formatter.format(cnpj)   # => "03.603.568/0001-95"
formatter.format(        # => "03.603.###/####-##"
  cnpj,
  hidden: true,
  hidden_key: '#',
  hidden_start: 5,
  hidden_end: 13
)
```

Padrões na instância; sobrescritas por chamada:

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new(hidden: true)
cnpj = '03603568000195'

formatter.format(cnpj)                 # usa mascaramento da instância
formatter.format(cnpj, hidden: false)  # só nesta chamada: sem máscara
formatter.format(cnpj)                 # volta aos padrões da instância
```

Entrada alfanumérica e array:

```ruby
require 'cnpj-fmt'

formatter = CnpjFmt::CnpjFormatter.new

formatter.format('RK0CMT3W000100')   # => "RK.0CM.T3W/0001-00"
formatter.format([                     # => "RK.0CM.T3W/0001-00"
  'RK',
  '0CM',
  'T3W',
  '0001',
  '00'
])
```

### Formatos de entrada

**String:** Dígitos e/ou letras brutos, ou CNPJ já formatado (ex.: `12.345.678/0009-10`, `12.ABC.345/00DE-99`). Caracteres não alfanuméricos são removidos; letras minúsculas viram maiúsculas.

**Array de strings:** Cada elemento deve ser `String`; os valores são concatenados (ex.: por dígito, segmentos agrupados ou misturados com pontuação — tudo é removido na normalização). Elementos que não sejam string não são permitidos.

### Opções de formatação

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-------------|
| `hidden` | `Boolean`, `nil` | `false` | Se truthy, substitui o intervalo inclusivo `[hidden_start, hidden_end]` na string normalizada de 14 caracteres antes de aplicar pontuação |
| `hidden_key` | `String`, `nil` | `'*'` | Substituição de cada posição oculta (pode ter vários caracteres ou ser vazia); não pode usar caracteres proibidos nas chaves |
| `hidden_start` | `Integer`, `nil` | `5` | Índice inicial `0`–`13` (inclusivo) |
| `hidden_end` | `Integer`, `nil` | `13` | Índice final `0`–`13` (inclusivo); se `hidden_start > hidden_end`, são trocados |
| `dot_key` | `String`, `nil` | `'.'` | Separador entre grupos `XX` / `XXX` / `XXX` |
| `slash_key` | `String`, `nil` | `'/'` | Separador antes do bloco da filial |
| `dash_key` | `String`, `nil` | `'-'` | Separador antes dos dois últimos caracteres |
| `escape` | `Boolean`, `nil` | `false` | Se truthy, escapa HTML na string final |
| `encode` | `Boolean`, `nil` | `false` | Se truthy, codifica a string final para URL (semelhante a `encodeURIComponent`) |
| `on_fail` | `Proc`, `nil` | veja abaixo | `(value, exception) -> String` — usado quando o comprimento sanitizado ≠ 14 |

O **`on_fail`** padrão retorna string vazia. A exceção passada em falhas de comprimento é **`CnpjFmt::InvalidLengthError`** (`actual_input`, `evaluated_input`, `expected_length`). O valor de retorno do callback deve ser `String`; caso contrário, é lançado **`CnpjFmt::TypeMismatchError`**.

Exemplo com todas as opções:

```ruby
require 'cnpj-fmt'

cnpj = '03603568000195'

CnpjFmt.cnpj_fmt(
  cnpj,
  hidden: true,
  hidden_key: '#',
  hidden_start: 5,
  hidden_end: 11,
  dot_key: ' ',
  slash_key: '|',
  dash_key: '_-_',
  escape: true,
  encode: true,
  on_fail: ->(value, _exception) { value.to_s }
)
```

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado para entrada ou opções). |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (tamanho, intervalo, caracteres proibidos). |

Todo erro customizado inclui o módulo marcador `CnpjFmt::Error`. Falhas de tamanho e intervalo herdam de `CnpjFmt::DomainError` (`RangeError`); falhas por caracteres proibidos usam `CnpjFmt::ValidationError` (`ArgumentError`) e **não** ficam sob `DomainError`.

**Importante:** `InvalidLengthError` é **construído e passado ao `on_fail`**, não levantado por `format` / `cnpj_fmt`. O pacote também define folhas do esqueleto ainda não usadas (`MissingArgumentError`, `InvalidArgumentCombinationError`) por consistência do monorepo.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CnpjFmt::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Entrada de CNPJ ou opção com tipo de dado incorreto |
| `CnpjFmt::InvalidLengthError` | `CnpjFmt::DomainError` | Erro de domínio | Tamanho após sanitização não é exatamente 14 (passado ao `on_fail`) |
| `CnpjFmt::OutOfRangeError` | `CnpjFmt::DomainError` | Erro de domínio | `hidden_start` / `hidden_end` fora de `0`–`13` |
| `CnpjFmt::ValidationError` | `ArgumentError` (+ `include Error`) | Erro de domínio | Opção de chave contém caractere proibido |

#### `CnpjFmt::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta ou constrói para o `on_fail`.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CnpjFmt::Error
  # tudo o que esta biblioteca levanta
```

#### `CnpjFmt::DomainError`

- **Herança:** `CnpjFmt::DomainError < RangeError` (inclui `CnpjFmt::Error`)
- **Categoria:** Erro de domínio — ancestral das falhas numéricas/de tamanho.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CnpjFmt::OutOfRangeError` / construir `InvalidLengthError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CnpjFmt::DomainError
  # OutOfRangeError, InvalidLengthError (quando você o reerguer) e outras subclasses de DomainError
```

#### `CnpjFmt::TypeMismatchError`

- **Herança:** `CnpjFmt::TypeMismatchError < TypeError` (inclui `CnpjFmt::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada de CNPJ não é `String` nem `Array` de strings, quando uma opção tem tipo errado, ou quando `on_fail` não retorna `String`.
- **Exemplo:**

```ruby
CnpjFmt::CnpjFormatter.new.format(12_345) # levanta CnpjFmt::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CnpjFmt::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CnpjFmt::InvalidLengthError`

- **Herança:** `CnpjFmt::InvalidLengthError < CnpjFmt::DomainError < RangeError` (inclui `CnpjFmt::Error`)
- **Categoria:** Erro de domínio — o tamanho de uma coleção ou string viola uma regra de negócio.
- **Quando é levantado:** Não é levantado por `format`; é construído e passado como segundo argumento ao `on_fail` quando o CNPJ sanitizado não contém exatamente 14 caracteres alfanuméricos.
- **Exemplo:**

```ruby
CnpjFmt::CnpjFormatter.new.format(
  'short',
  on_fail: ->(_value, error) {
    error # => #<CnpjFmt::InvalidLengthError ...>
    'invalid'
  }
) # => "invalid"
```

- **Como resgatar:** Trate dentro do `on_fail` (caso típico), ou resgate se você o reerguer:

```ruby
rescue CnpjFmt::InvalidLengthError
  # esta violação exata de tamanho

rescue CnpjFmt::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CnpjFmt::OutOfRangeError`

- **Herança:** `CnpjFmt::OutOfRangeError < CnpjFmt::DomainError < RangeError` (inclui `CnpjFmt::Error`)
- **Categoria:** Erro de domínio — um valor numérico viola uma regra de intervalo.
- **Quando é levantado:** Levantado quando `hidden_start` ou `hidden_end` está fora do intervalo inclusivo `0`–`13`.
- **Exemplo:**

```ruby
CnpjFmt::CnpjFormatterOptions.new(hidden_start: 14) # levanta CnpjFmt::OutOfRangeError
```

- **Como resgatar:**

```ruby
rescue CnpjFmt::OutOfRangeError
  # esta violação exata de intervalo

rescue CnpjFmt::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CnpjFmt::ValidationError`

- **Herança:** `CnpjFmt::ValidationError < ArgumentError` (inclui `CnpjFmt::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando uma opção de chave (`hidden_key`, `dot_key`, `slash_key`, `dash_key`) contém um caractere proibido.
- **Exemplo:**

```ruby
CnpjFmt::CnpjFormatterOptions.new(dot_key: 'å') # levanta CnpjFmt::ValidationError
```

- **Como resgatar:**

```ruby
rescue CnpjFmt::ValidationError
  # esta falha exata de validação de domínio

rescue CnpjFmt::Error
  # qualquer erro levantado por esta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Uma classe nativa — captura uso incorreto (e ValidationError, que herda ArgumentError).
rescue ArgumentError
  # CnpjFmt::ValidationError e qualquer outro ArgumentError (da biblioteca ou não)

# 2) CnpjFmt::DomainError — captura apenas violações de regra enraizadas em RangeError.
rescue CnpjFmt::DomainError
  # CnpjFmt::OutOfRangeError, CnpjFmt::InvalidLengthError e outras subclasses de DomainError

# 3) CnpjFmt::Error — captura tudo o que a biblioteca levanta.
rescue CnpjFmt::Error
  # todo erro customizado que inclui CnpjFmt::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CnpjFmt::OutOfRangeError
  # apenas CnpjFmt::OutOfRangeError
```

Atributos relevantes:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`, `option_name` (nil para entrada de CNPJ)
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `expected_length`
- `OutOfRangeError`: `option_name`, `actual_input`, `min_expected_value`, `max_expected_value`
- `ValidationError`: `option_name`, `actual_input`, `forbidden_characters`

## API

### Exportações

Após `require 'cnpj-fmt'`:

- **`CnpjFmt.cnpj_fmt`**: `(cnpj_input, options = nil, **keywords) -> String` — helper de conveniência.
- **`CnpjFmt::CnpjFormatter`**: Classe para formatar CNPJ com opções padrão opcionais; aceita `String` ou `Array<String>` em `format`.
- **`CnpjFmt::CnpjFormatterOptions`**: Classe que armazena opções; suporta mesclagem via construtor, `set` e argumentos nomeados.
- **`CnpjFmt::CNPJ_LENGTH`**: `14` (constante).
- **`CnpjFmt::VERSION`**: string de versão da gem.
- **Erros**: `CnpjFmt::Error`, `CnpjFmt::DomainError`, `CnpjFmt::TypeMismatchError`, `CnpjFmt::InvalidLengthError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError` (mais folhas do esqueleto ainda não usadas).

### Outros recursos disponíveis

- **`CnpjFmt::CnpjFormatterOptions::CNPJ_LENGTH`**: `14`.
- **`CnpjFmt::CnpjFormatterOptions::DISALLOWED_KEY_CHARACTERS`**: Caracteres proibidos em `hidden_key`, `dot_key`, `slash_key`, `dash_key`.
- **`CnpjFmt::CnpjFormatterOptions::DEFAULT_*`**: Valores padrão de cada opção.
- **`CnpjFmt::CnpjFormatterOptions.default_on_fail`**: Callback padrão compartilhado para falhas.

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
