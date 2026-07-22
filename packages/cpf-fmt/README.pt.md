![cpf-fmt para Ruby](https://br-utils.vercel.app/img/cover_cpf-fmt.jpg)

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para formatar CPF (Cadastro de Pessoas Físicas) como valor numérico de 11 dígitos, com opções de máscara, escape HTML e codificação para URL.

## Recursos

- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings; elementos do array são concatenados na ordem
- ✅ **Agnóstico ao formato**: Remove caracteres não numéricos antes de formatar (letras e pontuação são descartados)
- ✅ **Delimitadores personalizáveis**: `dot_key` e `dash_key` podem ser vazios ou strings de um ou vários caracteres
- ✅ **Mascaramento**: Ocultação opcional de um intervalo de índices com string de substituição configurável (`hidden`, `hidden_key`, `hidden_start`, `hidden_end`)
- ✅ **Saída HTML e URL**: `escape` opcional (entidades HTML) e `encode` opcional (codificação tipo componente de URI, semelhante ao `encodeURIComponent` do JavaScript)
- ✅ **Erro de tamanho sem exceção**: Comprimento inválido após sanitização é tratado via `on_fail` (o padrão retorna string vazia)
- ✅ **Dependências mínimas**: Apenas [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Erros de uso da API vs erros de domínio, com o marcador `CpfFmt::Error` para resgate em nível de biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cpf-fmt
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cpf-fmt'
```

## Require

```ruby
require 'cpf-fmt'
```

## Início rápido

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new

formatter.format('03603568195')      # => "036.035.681-95"
formatter.format('123.456.789-10')   # => "123.456.789-10"
formatter.format('12345678910')      # => "123.456.789-10"
```

Uso básico com o helper:

```ruby
require 'cpf-fmt'

cpf = '03603568195'

CpfFmt.cpf_fmt(cpf)                    # => "036.035.681-95"
CpfFmt.cpf_fmt(cpf, hidden: true)      # => "036.***.***-**"
CpfFmt.cpf_fmt(                        # => "036035681_95"
  cpf,
  dot_key: '',
  dash_key: '_'
)
```

## Utilização

Os pontos principais são a classe `CpfFmt::CpfFormatter`, a classe de opções `CpfFmt::CpfFormatterOptions` e o helper `CpfFmt.cpf_fmt`.

### `CpfFmt::CpfFormatter`

- **`initialize(options = nil, **keywords)`**: Opções padrão de formatação. Quando `options` é informado (uma instância de `CpfFmt::CpfFormatterOptions` ou um `Hash`) sozinho, ele determina as opções padrão; uma instância de `CpfFmt::CpfFormatterOptions` é armazenada por referência (alterações posteriores afetam chamadas futuras a `format` que não passarem opções por chamada), enquanto um `Hash` cria uma nova instância. Quando `options` é omitido (`nil`), as opções padrão são montadas exclusivamente a partir dos argumentos nomeados (`hidden:`, `hidden_key:`, `dot_key:`, …). Passar `options` junto com qualquer argumento nomeado não-`nil` lança `InvalidArgumentCombinationError` em vez de ignorar os keywords silenciosamente. Exemplo: `CpfFmt::CpfFormatter.new(hidden: true, dash_key: '_')`.
- **`options`**: Retorna o `CpfFmt::CpfFormatterOptions` da instância (o mesmo objeto usado internamente).
- **`format(cpf_input, options = nil, **keywords)`**: Formata um valor CPF.

  A entrada é normalizada removendo caracteres não numéricos. Se o comprimento após sanitização não for exatamente **11**, o callback **`on_fail`** é chamado com a entrada original e um `CpfFmt::DomainError` (`InvalidLengthError`); o valor de retorno do callback é o resultado (nada é lançado por comprimento).

  Se a entrada não for `String` nem `Array` de strings, é lançado **`CpfFmt::TypeMismatchError`**.

  `options` por chamada e argumentos nomeados nunca são mesclados: um argumento `options` informado sozinho sobrescreve totalmente os padrões da instância nesta chamada; caso contrário, qualquer keyword informado sobrescreve os padrões da instância nesta chamada. Quando nenhum dos dois é informado, os padrões da instância são usados como estão. Os padrões da instância nunca são mutados por uma sobrescrita por chamada. Passar `options` junto com qualquer keyword não-`nil` lança `InvalidArgumentCombinationError`.

### `CpfFmt::CpfFormatterOptions`

Armazena todas as configurações do formatador, com validação e suporte a mesclagem. Expõe propriedades: `hidden`, `hidden_key`, `hidden_start`, `hidden_end`, `dot_key`, `dash_key`, `escape`, `encode`, `on_fail`.

- **`initialize(options = nil, *extra_overrides, **keywords)`**: Opções padrão opcionais (`Hash` simples, instância de `CpfFmt::CpfFormatterOptions` ou argumentos nomeados), além de objetos extras de sobrescrita mesclados em ordem (as últimas sobrescritas prevalecem).
- **`all`**: Retorna uma cópia superficial em `Hash` de todas as opções atuais.
- **`copy`**: Retorna uma cópia superficial desta instância de opções.
- **`set(options)`**: Atualiza vários campos de uma vez; retorna `self`. Aceita um `Hash` ou outra instância de `CpfFmt::CpfFormatterOptions`. Valores `nil` explícitos na atualização mantêm o valor atual.
- **`set_hidden_range(hidden_start, hidden_end)`**: Valida índices em **`[0, 10]`** (inclusivos); se `hidden_start > hidden_end`, os valores são trocados. Argumentos `nil` usam os padrões (`DEFAULT_HIDDEN_START` / `DEFAULT_HIDDEN_END`).

**`hidden_start` / `hidden_end`**: Os índices referem-se à **string CPF normalizada de 11 dígitos** (antes de inserir pontuação). O intervalo inclusivo é substituído internamente por placeholders e depois por `hidden_key` (permite chaves com vários caracteres ou string vazia).

**Opções de chave** (`hidden_key`, `dot_key`, `dash_key`): Devem ser strings e não podem conter caracteres em `CpfFmt::CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS` (reservados para a lógica interna).

### Helper funcional

`CpfFmt.cpf_fmt` instancia um novo `CpfFmt::CpfFormatter` com os mesmos parâmetros do construtor e chama `format(cpf_input)` uma vez. Passe argumentos nomeados **ou** um `Hash`/instância de `CpfFmt::CpfFormatterOptions` para as opções — não ambos (passar ambos lança `InvalidArgumentCombinationError`):

```ruby
require 'cpf-fmt'

cpf = '03603568195'

CpfFmt.cpf_fmt(cpf)                # => "036.035.681-95"
CpfFmt.cpf_fmt(cpf, hidden: true)  # mascarado com padrões
CpfFmt.cpf_fmt(                    # => "036035681_95"
  cpf,
  dot_key: '',
  dash_key: '_'
)
CpfFmt.cpf_fmt(cpf, {              # forma com Hash
  hidden: true,
  hidden_key: '#'
})
```

### Exemplos orientados a objeto

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new
cpf = '12345678910'

formatter.format(cpf)   # => "123.456.789-10"
formatter.format(        # => "123.###.###-##"
  cpf,
  hidden: true,
  hidden_key: '#',
  hidden_start: 3,
  hidden_end: 10
)
```

Padrões na instância; sobrescritas por chamada:

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new(hidden: true)
cpf = '12345678910'

formatter.format(cpf)                 # usa mascaramento da instância
formatter.format(cpf, hidden: false)  # só nesta chamada: sem máscara
formatter.format(cpf)                 # volta aos padrões da instância
```

Entrada em array:

```ruby
require 'cpf-fmt'

formatter = CpfFmt::CpfFormatter.new

formatter.format([                   # => "123.456.789-10"
  '123',
  '456',
  '789',
  '10'
])
```

### Formatos de entrada

**String:** Dígitos brutos ou CPF já formatado (ex.: `123.456.789-10`, `123 456 789 10`). Caracteres não numéricos são removidos; zeros à esquerda são preservados.

**Array de strings:** Cada elemento deve ser `String`; os valores são concatenados (ex.: por dígito, segmentos agrupados ou misturados com pontuação — tudo que não for dígito é removido na normalização). Elementos que não sejam string não são permitidos.

### Opções de formatação

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-------------|
| `hidden` | `Boolean`, `nil` | `false` | Se truthy, substitui o intervalo inclusivo `[hidden_start, hidden_end]` na string normalizada de 11 dígitos antes de aplicar pontuação |
| `hidden_key` | `String`, `nil` | `'*'` | Substituição de cada posição oculta (pode ter vários caracteres ou ser vazia); não pode usar caracteres proibidos nas chaves |
| `hidden_start` | `Integer`, `nil` | `3` | Índice inicial `0`–`10` (inclusivo) |
| `hidden_end` | `Integer`, `nil` | `10` | Índice final `0`–`10` (inclusivo); se `hidden_start > hidden_end`, são trocados |
| `dot_key` | `String`, `nil` | `'.'` | Separador após o 3º e o 6º dígitos |
| `dash_key` | `String`, `nil` | `'-'` | Separador após o 9º dígito |
| `escape` | `Boolean`, `nil` | `false` | Se truthy, escapa HTML na string final |
| `encode` | `Boolean`, `nil` | `false` | Se truthy, codifica a string final para URL (semelhante a `encodeURIComponent`) |
| `on_fail` | `Proc`, `nil` | veja abaixo | `(value, error) -> String` — usado quando o comprimento sanitizado ≠ 11 |

O **`on_fail`** padrão retorna string vazia. Assinatura: `(original_input, error) -> String`, onde `error` é um **`CpfFmt::DomainError`** (atualmente um `InvalidLengthError` com `actual_input`, `evaluated_input`, `expected_length`). O valor de retorno do callback deve ser `String`; caso contrário, é lançado **`CpfFmt::TypeMismatchError`**.

Exemplo com todas as opções:

```ruby
require 'cpf-fmt'

cpf = '12345678910'

CpfFmt.cpf_fmt(
  cpf,
  hidden: true,
  hidden_key: '#',
  hidden_start: 3,
  hidden_end: 9,
  dot_key: ' ',
  dash_key: '_-_',
  escape: true,
  encode: true,
  on_fail: ->(value, _error) { value.to_s }
)
```

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado para entrada ou opções, ou combinação inválida de argumentos). |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (tamanho, intervalo, caracteres proibidos). |

Todo erro customizado inclui o módulo marcador `CpfFmt::Error`. Falhas de domínio (`InvalidLengthError`, `OutOfRangeError`, `ValidationError`) herdam de `CpfFmt::DomainError` (`RangeError`).

**Importante:** falhas de tamanho são **construídas como `InvalidLengthError` e passadas ao `on_fail` como `DomainError`**, não levantadas por `format` / `cpf_fmt`. Passar ao mesmo tempo um argumento `options` (instância/`Hash`) e argumentos nomeados lança `InvalidArgumentCombinationError`.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CpfFmt::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | Uso incorreto da API | Instância/`Hash` de `options` e argumentos nomeados passados ao mesmo tempo |
| `CpfFmt::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Entrada de CPF ou opção com tipo de dado incorreto |
| `CpfFmt::InvalidLengthError` | `CpfFmt::DomainError` | Erro de domínio | Tamanho após sanitização não é exatamente 11 (passado ao `on_fail` como `DomainError`) |
| `CpfFmt::OutOfRangeError` | `CpfFmt::DomainError` | Erro de domínio | `hidden_start` / `hidden_end` fora de `0`–`10` |
| `CpfFmt::ValidationError` | `CpfFmt::DomainError` | Erro de domínio | Opção de chave contém caractere proibido |

#### `CpfFmt::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta ou constrói para o `on_fail`.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CpfFmt::Error
  # tudo o que esta biblioteca levanta
```

#### `CpfFmt::DomainError`

- **Herança:** `CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — ancestral das falhas numéricas/de tamanho.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CpfFmt::OutOfRangeError` / construir `InvalidLengthError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CpfFmt::DomainError
  # OutOfRangeError, InvalidLengthError, ValidationError e outras subclasses de DomainError
```

#### `CpfFmt::TypeMismatchError`

- **Herança:** `CpfFmt::TypeMismatchError < TypeError` (inclui `CpfFmt::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada de CPF não é `String` nem `Array` de strings, quando uma opção tem tipo errado, ou quando `on_fail` não retorna `String`.
- **Exemplo:**

```ruby
CpfFmt::CpfFormatter.new.format(12_345) # levanta CpfFmt::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CpfFmt::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CpfFmt::InvalidLengthError`

- **Herança:** `CpfFmt::InvalidLengthError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — o tamanho de uma coleção ou string viola uma regra de negócio.
- **Quando é levantado:** Não é levantado por `format`; é construído e passado como segundo argumento `DomainError` ao `on_fail` quando o CPF sanitizado não contém exatamente 11 dígitos.
- **Exemplo:**

```ruby
CpfFmt::CpfFormatter.new.format(
  'short',
  on_fail: ->(_value, error) {
    error # => #<CpfFmt::InvalidLengthError ...> (um DomainError)
    'invalid'
  }
) # => "invalid"
```

- **Como resgatar:** Trate dentro do `on_fail` (caso típico), ou resgate se você o reerguer:

```ruby
rescue CpfFmt::InvalidLengthError
  # esta violação exata de tamanho

rescue CpfFmt::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CpfFmt::InvalidArgumentCombinationError`

- **Herança:** `CpfFmt::InvalidArgumentCombinationError < ArgumentError` (inclui `CpfFmt::Error`)
- **Categoria:** Uso incorreto da API — o chamador misturou padrões de argumentos mutuamente exclusivos.
- **Quando é levantado:** Levantado quando `CpfFormatter.new`, `#format` ou `cpf_fmt` recebe ao mesmo tempo um argumento `options` (instância ou `Hash`) e qualquer argumento nomeado não-`nil`.
- **Exemplo:**

```ruby
begin
  CpfFmt::CpfFormatter.new({ dash_key: '_' }, hidden: true)
rescue CpfFmt::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (hidden:, ...), not both.
end
```

- **Como resgatar:**

```ruby
rescue CpfFmt::InvalidArgumentCombinationError
  # combinação inválida de argumentos desta biblioteca

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta biblioteca
```

#### `CpfFmt::OutOfRangeError`

- **Herança:** `CpfFmt::OutOfRangeError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — um valor numérico viola uma regra de intervalo.
- **Quando é levantado:** Levantado quando `hidden_start` ou `hidden_end` está fora do intervalo inclusivo `0`–`10`.
- **Exemplo:**

```ruby
CpfFmt::CpfFormatterOptions.new(hidden_start: 11) # levanta CpfFmt::OutOfRangeError
```

- **Como resgatar:**

```ruby
rescue CpfFmt::OutOfRangeError
  # esta violação exata de intervalo

rescue CpfFmt::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CpfFmt::ValidationError`

- **Herança:** `CpfFmt::ValidationError < CpfFmt::DomainError < RangeError` (inclui `CpfFmt::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando uma opção de chave (`hidden_key`, `dot_key`, `dash_key`) contém um caractere proibido.
- **Exemplo:**

```ruby
CpfFmt::CpfFormatterOptions.new(dot_key: 'å') # levanta CpfFmt::ValidationError
```

- **Como resgatar:**

```ruby
rescue CpfFmt::ValidationError
  # esta falha exata de validação de domínio

rescue CpfFmt::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Uma classe nativa — captura uso incorreto de tipo desta biblioteca (e outros TypeError).
rescue TypeError
  # CpfFmt::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CpfFmt::DomainError — captura violações de regra de negócio sob DomainError.
rescue CpfFmt::DomainError
  # CpfFmt::OutOfRangeError, CpfFmt::InvalidLengthError, CpfFmt::ValidationError
  # e outras subclasses de DomainError

# 3) CpfFmt::Error — captura tudo o que a biblioteca levanta.
rescue CpfFmt::Error
  # todo erro customizado que inclui CpfFmt::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CpfFmt::OutOfRangeError
  # apenas CpfFmt::OutOfRangeError
```

Atributos relevantes:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`, `option_name` (nil para entrada de CPF)
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `expected_length`
- `OutOfRangeError`: `option_name`, `actual_input`, `min_expected_value`, `max_expected_value`
- `ValidationError`: `option_name`, `actual_input`, `forbidden_characters`

## API

### Exportações

Após `require 'cpf-fmt'`:

- **`CpfFmt.cpf_fmt`**: `(cpf_input, options = nil, **keywords) -> String` — helper de conveniência.
- **`CpfFmt::CpfFormatter`**: Classe para formatar CPF com opções padrão opcionais; aceita `String` ou `Array<String>` em `format`.
- **`CpfFmt::CpfFormatterOptions`**: Classe que armazena opções; suporta mesclagem via construtor, `set` e argumentos nomeados.
- **`CpfFmt::CPF_LENGTH`**: `11` (constante).
- **`CpfFmt::VERSION`**: string de versão da gem.
- **Predicado de tipo**: `CpfFmt::CpfInput` — `CpfFmt::CpfInput.accept?(value)` / `CpfFmt::CpfInput === value` é verdadeiro apenas para `String` ou `Array<String>`.
- **Erros**: `CpfFmt::Error`, `CpfFmt::DomainError`, `CpfFmt::InvalidArgumentCombinationError`, `CpfFmt::TypeMismatchError`, `CpfFmt::InvalidLengthError`, `CpfFmt::OutOfRangeError`, `CpfFmt::ValidationError`.

### Outros recursos disponíveis

- **`CpfFmt::CpfFormatterOptions::CPF_LENGTH`**: `11`.
- **`CpfFmt::CpfFormatterOptions::DISALLOWED_KEY_CHARACTERS`**: Caracteres proibidos em `hidden_key`, `dot_key`, `dash_key`.
- **`CpfFmt::CpfFormatterOptions::DEFAULT_*`**: Valores padrão de cada opção.
- **`CpfFmt::CpfFormatterOptions.default_on_fail`**: Callback padrão compartilhado para falhas.

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
