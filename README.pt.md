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
- ✅ **Tratamento de erros**: Erros de tipo para uso incorreto da API; validação de opções com exceções específicas

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

  A entrada é normalizada removendo caracteres não alfanuméricos e convertendo para maiúsculas. Se o comprimento após sanitização não for exatamente **14**, o callback **`on_fail`** é chamado com a entrada original e uma `CnpjFmt::CnpjFormatterInputLengthException`; o valor de retorno do callback é o resultado (nada é lançado por comprimento).

  Se a entrada não for `String` nem `Array` de strings, é lançada **`CnpjFmt::CnpjFormatterInputTypeError`**.

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

O **`on_fail`** padrão retorna string vazia. A exceção passada em falhas de comprimento é **`CnpjFmt::CnpjFormatterInputLengthException`** (`actual_input`, `evaluated_input`, `expected_length`). O valor de retorno do callback deve ser `String`; caso contrário, é lançada **`CnpjFmt::CnpjFormatterOptionsTypeError`**.

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

### Erros e exceções

Este pacote usa a semântica **TypeError vs StandardError**: *erros de tipo* indicam uso incorreto da API (ex.: tipo errado); *exceções* indicam dados inválidos ou inelegíveis passados a callbacks ou validação de opções.

- **Tipo de entrada incorreto** (não `String` nem `Array` de strings): **`CnpjFmt::CnpjFormatterInputTypeError`** — estende **`CnpjFmt::CnpjFormatterTypeError`** (estende `TypeError` nativo).
- **Tipos ou valores de opção inválidos ao construir ou mesclar opções**: **`CnpjFmt::CnpjFormatterOptionsTypeError`**, **`CnpjFmt::CnpjFormatterOptionsHiddenRangeInvalidException`**, **`CnpjFmt::CnpjFormatterOptionsForbiddenKeyCharacterException`** — estendem **`CnpjFmt::CnpjFormatterTypeError`** ou **`CnpjFmt::CnpjFormatterException`** conforme o caso.

Diferença de comprimento **não** lança exceção em `format`; trate dentro de **`on_fail`**.

```ruby
require 'cnpj-fmt'

begin
  CnpjFmt::CnpjFormatter.new.format(12_345)
rescue CnpjFmt::CnpjFormatterInputTypeError => e
  puts e.message
end

CnpjFmt::CnpjFormatter.new.format(
  'short',
  on_fail: ->(_value, _exception) { 'invalid' }
) # => "invalid"
```

Atributos notáveis nos erros lançados:

- `CnpjFormatterInputTypeError`: `actual_input`, `actual_type`, `expected_type`
- `CnpjFormatterOptionsTypeError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `CnpjFormatterInputLengthException`: `actual_input`, `evaluated_input`, `expected_length`
- `CnpjFormatterOptionsHiddenRangeInvalidException`: `option_name`, `actual_input`, `min_expected_value`, `max_expected_value`
- `CnpjFormatterOptionsForbiddenKeyCharacterException`: `option_name`, `actual_input`, `forbidden_characters`

## API

### Exportações

Após `require 'cnpj-fmt'`:

- **`CnpjFmt.cnpj_fmt`**: `(cnpj_input, options = nil, **keywords) -> String` — helper de conveniência.
- **`CnpjFmt::CnpjFormatter`**: Classe para formatar CNPJ com opções padrão opcionais; aceita `String` ou `Array<String>` em `format`.
- **`CnpjFmt::CnpjFormatterOptions`**: Classe que armazena opções; suporta mesclagem via construtor, `set` e argumentos nomeados.
- **`CnpjFmt::CNPJ_LENGTH`**: `14` (constante).
- **`CnpjFmt::VERSION`**: string de versão da gem.
- **Exceções**: `CnpjFmt::CnpjFormatterTypeError`, `CnpjFmt::CnpjFormatterInputTypeError`, `CnpjFmt::CnpjFormatterOptionsTypeError`, `CnpjFmt::CnpjFormatterException`, `CnpjFmt::CnpjFormatterInputLengthException`, `CnpjFmt::CnpjFormatterOptionsHiddenRangeInvalidException`, `CnpjFmt::CnpjFormatterOptionsForbiddenKeyCharacterException`.

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
