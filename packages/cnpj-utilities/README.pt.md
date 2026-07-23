![cnpj-utilities para Ruby](https://br-utils.vercel.app/img/cover_cnpj-utils.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](./README.md)

Kit em Ruby para formatar, gerar e validar CNPJ (Cadastro Nacional da Pessoa Jurídica). Envolve [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt), [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen) e [`cnpj-val`](https://rubygems.org/gems/cnpj-val) em uma única classe fachada (`CnpjUtils`).

## Recursos

- ✅ **API unificada**: Helpers de classe `CnpjUtils.format` / `.generate` / `.is_valid` (aliases de `CnpjUtils::DEFAULT`); `DEFAULT` mutável para ajustes compartilhados
- ✅ **Acesso em dois níveis**: Prefira `CnpjUtils::CnpjFormatter` / `CnpjGenerator` / `CnpjValidator` para as classes principais; Options, helpers e erros ficam em `CnpjUtils::CnpjFmt` / `CnpjGen` / `CnpjVal` (os irmãos na raiz `CnpjFmt` / `CnpjGen` / `CnpjVal` continuam funcionando)
- ✅ **CNPJ alfanumérico**: Formatar, gerar e validar CNPJ de 14 caracteres numérico ou alfanumérico
- ✅ **Instância reutilizável**: Classe `CnpjUtils` com configurações padrão opcionais (opções ou instâncias do formatador, gerador e validador)
- ✅ **Entrada flexível**: `#format` e `#is_valid` aceitam `String` ou `Array` de strings (elementos concatenados na ordem)
- ✅ **Sobrescritas por chamada**: Padrões da instância mais um `Hash`/instância `*Options` por chamada **ou** sobrescritas por palavra-chave (não ambos)
- ✅ **Tratamento de erros**: Erros dos componentes propagam inalterados; esta gem também define `CnpjUtils::InvalidArgumentCombinationError` para uso indevido de settings/options vs palavras-chave

## Instalação

Instale a gem diretamente:

```bash
gem install cnpj-utilities
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cnpj-utilities'
```

Isso instala **`cnpj-utilities`** junto com [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt), [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen) e [`cnpj-val`](https://rubygems.org/gems/cnpj-val). Você **não** precisa de `gem install` / linhas `gem` separados para os pacotes componentes ao usar **`cnpj-utilities`**.

## Require

```ruby
require 'cnpj-utilities'
```

## Início rápido

Uso básico com helpers de classe (aliases de `CnpjUtils::DEFAULT`):

```ruby
require 'cnpj-utilities'

cnpj = '03603568000195'

CnpjUtils.format(cnpj)                # => "03.603.568/0001-95"
CnpjUtils.format(cnpj, hidden: true)  # => "03.603.***/****-**"
CnpjUtils.format(                     # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)

CnpjUtils.generate                    # => ex.: "AB123CDE000155" (14 caracteres alfanuméricos)
CnpjUtils.generate(format: true)      # => ex.: "AB.123.CDE/0001-55"
CnpjUtils.generate(prefix: '45623767') # => ex.: "45623767000296"
CnpjUtils.generate(type: 'numeric')   # => ex.: "65453043000178" (apenas dígitos)

CnpjUtils.is_valid('98765432000198')       # => true
CnpjUtils.is_valid('98.765.432/0001-98')   # => true
CnpjUtils.is_valid('1QB5UKALPYFP59')       # => true (alfanumérico)
CnpjUtils.is_valid('98765432000199')       # => false
```

## Utilização

Você pode trabalhar destas formas equivalentes:

1. **`CnpjUtils.format` / `.generate` / `.is_valid`** — helpers de classe para chamadas rápidas (encaminham para `DEFAULT`).
2. **`CnpjUtils::DEFAULT`** — singleton compartilhado mutável (o mesmo objeto usado pelos helpers de classe).
3. **`CnpjUtils.new`** — instância configurável com padrões compartilhados entre formatar, gerar e validar.
4. **Classes principais sob `CnpjUtils`** — `CnpjUtils::CnpjFormatter`, `CnpjUtils::CnpjGenerator`, `CnpjUtils::CnpjValidator`.
5. **Módulos aninhados do pacote** — Options, helpers, erros e tipos via `CnpjUtils::CnpjFmt` / `CnpjGen` / `CnpjVal` (ex.: `CnpjUtils::CnpjFmt::CnpjFormatterOptions`, `CnpjUtils::CnpjFmt.cnpj_fmt`).
6. **Módulos irmãos na raiz** (ainda suportados) — `CnpjFmt`, `CnpjGen`, `CnpjVal` inalterados.

Todas as abordagens expõem as mesmas opções e comportamento. Para tabelas de opções exaustivas e detalhes específicos de cada componente, consulte o README de cada [pacote incluído](#pacotes-incluídos).

### Opções do formatador

Em `#format(cnpj_input, options = nil, **keywords)`, todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | Se `true`, mascara caracteres entre `hidden_start` e `hidden_end` com `hidden_key` |
| `hidden_key` | `String` | `'*'` | Caractere(s) usados para substituir os caracteres mascarados |
| `hidden_start` | `Integer` | `5` | Índice inicial (0–13, inclusivo) do intervalo a ocultar |
| `hidden_end` | `Integer` | `13` | Índice final (0–13, inclusivo) do intervalo a ocultar |
| `dot_key` | `String` | `'.'` | Delimitador de ponto (ex.: em `12.345.678`) |
| `slash_key` | `String` | `'/'` | Delimitador de barra (ex.: antes da filial `…/0001-90`) |
| `dash_key` | `String` | `'-'` | Delimitador de hífen (ex.: antes dos dígitos verificadores `…-90`) |
| `escape` | `Boolean` | `false` | Se `true`, escapa caracteres especiais HTML no resultado |
| `encode` | `Boolean` | `false` | Se `true`, codifica o resultado para URL (similar ao `encodeURIComponent` do JavaScript) |
| `on_fail` | `Proc` / invocável | retorna `''` | Callback quando o tamanho da entrada sanitizada ≠ 14; o retorno é usado como resultado |

### Opções do gerador

Em `#generate(options = nil, **keywords)`, todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se `true`, retorna o CNPJ gerado no formato padrão (`00.000.000/0000-00`) |
| `prefix` | `String` | `''` | String inicial parcial (0–12 caracteres alfanuméricos). Os caracteres faltantes são gerados e os dígitos verificadores calculados. |
| `type` | `String` | `'alphanumeric'` | Conjunto de caracteres da parte gerada aleatoriamente: `'numeric'`, `'alphabetic'` ou `'alphanumeric'`. **Os dígitos verificadores são sempre numéricos.** |

Regras do prefixo: a base (primeiros 8 caracteres) e a filial (caracteres 9–12) não podem ser todos zeros; 12 dígitos repetidos (ex.: `111111111111`) também não são permitidos.

### Opções do validador

Em `#is_valid(cnpj_input, options = nil, **keywords)`, todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `case_sensitive` | `Boolean` | `true` | Se `false`, letras minúsculas são aceitas para CNPJ alfanumérico (a entrada é convertida para maiúsculas antes da validação). |
| `type` | `String` | `'alphanumeric'` | `'numeric'`: apenas dígitos (0–9); `'alphanumeric'`: dígitos e letras (0–9, A–Z). |

### Helpers de classe (`CnpjUtils.format` / `.generate` / `.is_valid`)

Esses métodos de classe são aliases dos mesmos métodos em `CnpjUtils::DEFAULT`. Prefira-os para chamadas pontuais:

```ruby
CnpjUtils.format('03603568000195')
CnpjUtils.generate(type: 'numeric')
CnpjUtils.is_valid('98765432000198')
```

### `CnpjUtils::DEFAULT` (instância padrão)

`CnpjUtils::DEFAULT` é o singleton pré-construído e **mutável** por trás dos helpers de classe (paridade com o export padrão do JS / `cnpj_utils` do Python). Mutá-lo afeta chamadas seguintes a `CnpjUtils.format` / `.generate` / `.is_valid`; instâncias `CnpjUtils.new` personalizadas permanecem independentes:

```ruby
CnpjUtils::DEFAULT.formatter = { slash_key: '|' }
CnpjUtils.format('01ABC234000X56')  # => "01.ABC.234|000X-56"

custom = CnpjUtils.new
custom.format('01ABC234000X56')     # => "01.ABC.234/000X-56" (não afetado)
```

Métodos de instância em `DEFAULT` (e em qualquer instância de `CnpjUtils`):

- **`#format(cnpj_input, options = nil, **keywords)`**: Formata uma string CNPJ ou array de strings. Delega ao formatador interno. A entrada deve ter 14 caracteres alfanuméricos (após sanitização); caso contrário, `on_fail` é usado.
- **`#generate(options = nil, **keywords)`**: Gera um CNPJ válido. Delega ao gerador interno.
- **`#is_valid(cnpj_input, options = nil, **keywords)`**: Retorna `true` se o CNPJ for válido. Delega ao validador interno.

### `CnpjUtils` (classe)

Para formatador, gerador ou validador padrão personalizados, crie sua própria instância:

```ruby
require 'cnpj-utilities'

utils = CnpjUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { type: 'numeric', format: true },
  validator: { type: 'numeric', case_sensitive: false }
)

utils.format('RK0CMT3W000100')        # => "RK.0CM.###/####-##"
utils.generate                        # => ex.: "73.008.535/0005-06"
utils.is_valid('98.765.432/0001-98')  # => true

# Acessar ou substituir instâncias internas
utils.formatter  # => CnpjFmt::CnpjFormatter
utils.generator  # => CnpjGen::CnpjGenerator
utils.validator  # => CnpjVal::CnpjValidator
```

- **`CnpjUtils.new(settings = nil, **keywords)`**: Configurações opcionais. Passe um `Hash` de settings com as chaves `:formatter`, `:generator` e/ou `:validator`, **ou** as mesmas chaves como argumentos nomeados — não ambos (passar ambos lança `CnpjUtils::InvalidArgumentCombinationError`). Cada valor pode ser uma instância de componente, uma instância `*Options` (armazenada por referência — mutá-la depois afeta chamadas subsequentes sem sobrescrita por chamada), um `Hash` de opções, ou omitido/`nil` para os padrões.
- **`#format(cnpj_input, options = nil, **keywords)`**: Igual à instância padrão; opções por chamada sobrescrevem os padrões do formatador apenas nessa chamada. Passe um `Hash`/`CnpjFmt::CnpjFormatterOptions` **ou** sobrescritas por palavra-chave — não ambos.
- **`#generate(options = nil, **keywords)`**: Igual à instância padrão; opções por chamada sobrescrevem os padrões do gerador. Passe um `Hash`/`CnpjGen::CnpjGeneratorOptions` **ou** sobrescritas por palavra-chave — não ambos.
- **`#is_valid(cnpj_input, options = nil, **keywords)`**: Igual à instância padrão; opções por chamada sobrescrevem os padrões do validador. Passe um `Hash`/`CnpjVal::CnpjValidatorOptions` **ou** sobrescritas por palavra-chave — não ambos.
- **`#formatter`**, **`#generator`**, **`#validator`**: Acessores (getters e setters) dos componentes internos. Os setters aceitam as mesmas formas do construtor. Para alterar uma única opção sem substituir a instância, mute as opções do componente (ex.: `utils.formatter.options.hidden = true`).

Padrões da instância e sobrescritas por chamada:

```ruby
require 'cnpj-utilities'

utils = CnpjUtils.new(
  formatter: { hidden: true, hidden_key: '#' },
  generator: { format: true },
  validator: { type: 'numeric' }
)

cnpj = '03603568000195'

utils.format(cnpj)                 # mascarado (padrões do formatador da instância)
utils.format(cnpj, hidden: false)  # só nesta chamada: sem máscara
utils.generate(format: false)      # só nesta chamada: saída compacta
utils.is_valid('1QB5UKALPYFP59')   # => false (validador da instância é só numérico)
utils.is_valid(                    # => true nesta chamada
  '1QB5UKALPYFP59',
  type: 'alphanumeric'
)
```

As opções também podem ser passadas como `Hash` (ou instância de opções) em cada método — sem sobrescritas por palavra-chave:

```ruby
utils.format(cnpj, { slash_key: '|' })
utils.generate({ prefix: '12345', type: 'numeric' })
utils.is_valid('1QB5UKALPYFP59', { case_sensitive: false })
```

### Usando classes de componente e módulos aninhados

Caminhos preferidos após `require 'cnpj-utilities'`:

```ruby
require 'cnpj-utilities'

# Classes principais na raiz da fachada
formatter = CnpjUtils::CnpjFormatter.new(hidden: true)
generator = CnpjUtils::CnpjGenerator.new(type: 'numeric')
validator = CnpjUtils::CnpjValidator.new

formatter.format('AB123XYZ000123')  # => "AB.123.***/****-**"

# Options, helpers e erros sob os módulos aninhados do pacote
options = CnpjUtils::CnpjFmt::CnpjFormatterOptions.new(slash_key: '|')
CnpjUtils::CnpjFmt.cnpj_fmt('03603568000195')  # => "03.603.568/0001-95"

begin
  CnpjUtils::CnpjFmt.cnpj_fmt(12_345)
rescue CnpjUtils::CnpjFmt::TypeMismatchError
  # tipo de entrada incorreto
end
```

Os irmãos na raiz continuam suportados (os mesmos objetos que os aninhados):

```ruby
CnpjFmt.cnpj_fmt('01ABC234000X56', slash_key: '|')  # => "01.ABC.234|000X-56"
CnpjGen.cnpj_gen(type: 'numeric')                   # => ex.: "65453043000178"
CnpjVal.cnpj_val('9JN7MGLJZXIO50')                  # => true
CnpjFmt::CnpjFormatter.new(hidden: true)
```

Consulte [`cnpj-fmt`](../cnpj-fmt/README.pt.md), [`cnpj-gen`](../cnpj-gen/README.pt.md) e [`cnpj-val`](../cnpj-val/README.pt.md) para detalhes completos de opções e erros.

## API

### Exportações

Após `require 'cnpj-utilities'`:

- **`CnpjUtils`**: Classe fachada para criar uma instância com configurações padrão opcionais de formatador, gerador e validador.
- **`CnpjUtils.format` / `.generate` / `.is_valid`**: Helpers de classe que encaminham para `CnpjUtils::DEFAULT`.
- **`CnpjUtils::DEFAULT`**: Instância pré-construída mutável de `CnpjUtils` (o mesmo objeto usado pelos helpers de classe).
- **`CnpjUtils::VERSION`**: String da versão da gem.
- **Atalhos das classes principais**: `CnpjUtils::CnpjFormatter`, `CnpjUtils::CnpjGenerator`, `CnpjUtils::CnpjValidator` (os mesmos objetos das classes irmãs).
- **Módulos aninhados do pacote**: `CnpjUtils::CnpjFmt`, `CnpjUtils::CnpjGen`, `CnpjUtils::CnpjVal` — superfície completa do irmão (Options, helpers, erros, tipos). Options/helpers/erros **não** são aliasados na raiz de `CnpjUtils`.
- **Módulos irmãos na raiz** (ainda suportados): `CnpjFmt`, `CnpjGen`, `CnpjVal` — os mesmos objetos que os aninhados.

### Erros e exceções

`CnpjUtils` define apenas erros de uso indevido da API para as regras de argumentos desta gem. Erros de componentes são lançados pelos pacotes incluídos e propagam inalterados.

#### Definidos por `cnpj-utilities`

| Erro | Pai | Categoria | Quando |
|------|-----|-----------|--------|
| `CnpjUtils::Error` | módulo marcador | N/A | Incluído em todo erro customizado que esta gem lança |
| `CnpjUtils::InvalidArgumentCombinationError` | `ArgumentError` | Uso indevido da API | `Hash` de settings/options (ou instância de opções) passado junto com qualquer argumento nomeado não-`nil` |

```ruby
require 'cnpj-utilities'

begin
  CnpjUtils.new({ formatter: { hidden: true } }, generator: { format: true })
rescue CnpjUtils::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either a settings Hash to `settings`, or keyword arguments
  # (formatter:, generator:, validator:), not both.
end

begin
  CnpjUtils.format('03603568000195', { hidden: true }, slash_key: '|')
rescue CnpjUtils::InvalidArgumentCombinationError
  # Hash/instância de opções e sobrescritas por palavra-chave são mutuamente exclusivos
end
```

Resgate tudo o que esta gem lança com:

```ruby
rescue CnpjUtils::Error
  # InvalidArgumentCombinationError e quaisquer erros customizados futuros desta gem
```

#### Propagados dos pacotes incluídos

- **Formatação** (`CnpjFmt`): `CnpjFmt::TypeMismatchError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError`, `CnpjFmt::InvalidLengthError` (passado a `on_fail`, não lançado por `#format`) e classes relacionadas.
- **Geração** (`CnpjGen`): `CnpjGen::TypeMismatchError`, `CnpjGen::ValidationError` e classes relacionadas.
- **Validação** (`CnpjVal`): `CnpjVal::TypeMismatchError`, `CnpjVal::ValidationError` e classes relacionadas.

Tipos de opção inválidos são tipicamente subclasses de **`TypeError`** (`*::TypeMismatchError`); valores de opção inválidos são erros de domínio sob a hierarquia `DomainError` de cada pacote. Falha de validação retorna `false`; falha de comprimento na formatação é tratada por **`on_fail`** (o padrão retorna string vazia).

```ruby
require 'cnpj-utilities'

begin
  CnpjUtils.new.format(12_345)
rescue CnpjFmt::TypeMismatchError => e
  puts e.message
end

begin
  CnpjUtils.new.is_valid(12_345_678_000_198)
rescue CnpjVal::TypeMismatchError => e
  puts e.message
end

# on_fail personalizado para comprimento inválido
custom_fail = ->(value, _exception) { "CNPJ inválido: #{value}" }

CnpjFmt.cnpj_fmt('123', on_fail: custom_fail)  # => "CNPJ inválido: 123"
CnpjFmt.cnpj_fmt('123')                        # => "" (on_fail padrão)
```

### Pacotes incluídos

| Pacote | Principais recursos | README |
|--------|---------------------|--------|
| [`cnpj-fmt`](https://rubygems.org/gems/cnpj-fmt) | `CnpjFmt::CnpjFormatter`, `CnpjFmt::CnpjFormatterOptions`, `CnpjFmt.cnpj_fmt` | [docs](../cnpj-fmt/README.pt.md) |
| [`cnpj-gen`](https://rubygems.org/gems/cnpj-gen) | `CnpjGen::CnpjGenerator`, `CnpjGen::CnpjGeneratorOptions`, `CnpjGen.cnpj_gen` | [docs](../cnpj-gen/README.pt.md) |
| [`cnpj-val`](https://rubygems.org/gems/cnpj-val) | `CnpjVal::CnpjValidator`, `CnpjVal::CnpjValidatorOptions`, `CnpjVal.cnpj_val` | [docs](../cnpj-val/README.pt.md) |

Todos os pacotes acima são instalados como dependências de **`cnpj-utilities`**. Para tabelas de opções exaustivas, listas de exceções e comportamento em casos extremos, consulte o README de cada pacote.

## Contribuição e suporte

Contribuições são bem-vindas! Consulte as [Diretrizes de contribuição](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md). Se o projeto for útil para você, considere:

- ⭐ Dar uma estrela no repositório
- 🤝 Contribuir com código
- 💡 [Sugerir novas funcionalidades](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reportar bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## Licença

Este projeto está sob a licença MIT — veja o arquivo [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE).

## Changelog

Veja o [CHANGELOG](./CHANGELOG.md) para alterações e histórico de versões.

---

Feito com ❤️ por [Lacus Solutions](https://github.com/LacusSolutions)
