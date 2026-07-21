![cpf-val para Ruby](https://br-utils.vercel.app/img/cover_cpf-val.jpg)

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para validar CPF (Cadastro de Pessoa Física).

## Recursos

- ✅ **CPF de 11 dígitos**: Valida o CPF brasileiro padrão de 11 dígitos pelo algoritmo oficial de módulo 11
- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings; elementos do array são concatenados na ordem
- ✅ **Agnóstico ao formato**: Remove todos os caracteres não numéricos antes de validar
- ✅ **Rejeição de dígitos repetidos**: Bases com todos os dígitos iguais (ex.: `111.111.111-11`, `00000000000`) são rejeitadas
- ✅ **Tratamento de erros**: Erros tipados de uso incorreto da API, com marcador `CpfVal::Error` para rescue em toda a biblioteca
- ✅ **Dependências mínimas**: [`cpf-dv`](https://rubygems.org/gems/cpf-dv) para cálculo dos dígitos verificadores e [`lacus-utils`](https://rubygems.org/gems/lacus-utils) para descrição de tipos nas mensagens de erro
- ✅ **API dupla**: Orientada a objetos (`CpfVal::CpfValidator`) e funcional (`CpfVal.cpf_val`)

## Instalação

Instale a gem diretamente:

```bash
gem install cpf-val
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cpf-val'
```

## Require

```ruby
require 'cpf-val'
```

## Início rápido

```ruby
require 'cpf-val'

validator = CpfVal::CpfValidator.new

validator.is_valid('12345678909')       # => true
validator.is_valid('123.456.789-09')    # => true
validator.is_valid('12345678910')       # => false (dígitos verificadores inválidos)
validator.is_valid('00000000000')       # => false (dígitos repetidos)
```

Helper funcional:

```ruby
require 'cpf-val'

CpfVal.cpf_val('12345678909')      # => true
CpfVal.cpf_val('123.456.789-09')   # => true
CpfVal.cpf_val('12345678910')      # => false
```

## Utilização

Os pontos principais são a classe `CpfVal::CpfValidator` e o helper `CpfVal.cpf_val`.

### `CpfVal::CpfValidator`

- **`initialize`**: Não recebe argumentos. A validação de CPF não possui opções de configuração.
- **`is_valid(cpf_input)`**: Valida um valor CPF.

  A entrada é normalizada para string (arrays de strings são concatenados). Em seguida, todos os caracteres não numéricos são removidos. Se o comprimento após sanitização não for exatamente **11**, se a base for uma sequência de dígitos todos iguais ou se os dígitos verificadores não coincidirem (`CpfDV::CpfCheckDigits` de **`cpf-dv`**), o método retorna `false` — nenhuma exceção é lançada por falha de validação.

  Se a entrada não for `String` nem `Array` de strings, é lançada **`CpfVal::TypeMismatchError`**.

```ruby
require 'cpf-val'

validator = CpfVal::CpfValidator.new

validator.is_valid('123.456.789-09')             # => true
validator.is_valid('12345678909')                # => true
validator.is_valid(['123', '456', '789', '09'])  # => true
validator.is_valid('12345678910')                # => false (dígitos verificadores inválidos)
validator.is_valid('11111111111')                # => false (dígitos repetidos)
```

### Helper funcional

`CpfVal.cpf_val` instancia um novo `CpfVal::CpfValidator` e chama `is_valid(cpf_input)` uma vez. Recebe apenas o valor de entrada:

```ruby
require 'cpf-val'

CpfVal.cpf_val('11144477735')      # => true
CpfVal.cpf_val('111.444.777-35')   # => true
CpfVal.cpf_val('11144477736')      # => false
```

### Formatos de entrada

**String:** Apenas dígitos ou CPF já formatado (ex.: `123.456.789-09`, `499.784.420-90`, `011_258_960_00`). Caracteres não numéricos são removidos antes da validação; o resultado deve ter exatamente 11 dígitos.

**Array de strings:** Cada elemento deve ser `String`; os valores são concatenados (ex.: por dígito, segmentos agrupados ou misturados com pontuação). Elementos que não sejam string lançam **`CpfVal::TypeMismatchError`**.

```ruby
require 'cpf-val'

CpfVal.cpf_val(['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '9'])  # => true
CpfVal.cpf_val(['123.456', '789-09'])  # => true
```

### Tratamento de erros

Este pacote levanta erro apenas por **uso incorreto da API** (tipo de entrada incorreto). Falhas de validação (comprimento incorreto, base inelegível como dígitos repetidos, dígitos verificadores inválidos) retornam `false` e não levantam exceção.

Todo erro customizado inclui o módulo marcador `CpfVal::Error`.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CpfVal::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Entrada CPF não é `String` nem `Array` de strings |

#### `CpfVal::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de rescue) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca levantado diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatá-lo:**

```ruby
rescue CpfVal::Error
  # tudo o que esta biblioteca levanta
```

#### `CpfVal::TypeMismatchError`

- **Herança:** `CpfVal::TypeMismatchError < TypeError` (inclui `CpfVal::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada CPF não é `String` nem `Array` de strings (incluindo quando um array contém um elemento que não é string).
- **Exemplo:**

```ruby
require 'cpf-val'

begin
  CpfVal.cpf_val(12_345_678_909)
rescue CpfVal::TypeMismatchError => e
  puts e.message
  # CPF input must be of type string or string[]. Got integer number.
end
```

- **Como resgatá-lo:**

```ruby
rescue CpfVal::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Classe nativa única — captura erros de uso incorreto desse tipo.
rescue TypeError
  # CpfVal::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CpfVal::Error — captura tudo o que a biblioteca levanta.
rescue CpfVal::Error
  # todo erro customizado que inclui CpfVal::Error

# 3) Classe folha específica — captura apenas aquele modo de falha.
rescue CpfVal::TypeMismatchError
  # apenas CpfVal::TypeMismatchError
```

Atributos notáveis nos erros levantados:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`

## API

### Exportações

Após `require 'cpf-val'`:

- **`CpfVal.cpf_val`**: `(cpf_input) -> Boolean` — helper de conveniência.
- **`CpfVal::CpfValidator`**: Classe para validar CPF (sem opções); aceita `String` ou `Array<String>` em `is_valid`.
- **`CpfVal::CPF_LENGTH`**: `11` (constante).
- **`CpfVal::VERSION`**: string de versão da gem.
- **Marcador de tipo**: `CpfVal::CpfInput`.
- **Erros**: `CpfVal::Error`, `CpfVal::TypeMismatchError`.

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
