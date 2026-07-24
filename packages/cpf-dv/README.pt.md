![cpf-dv para Ruby](https://br-utils.vercel.app/img/cover_cpf-dv.jpg)

> 🌎 [Access documentation in English](https://github.com/LacusSolutions/br-utils-ruby/blob/main/packages/cpf-dv/README.md)

Utilitário em Ruby para calcular os dígitos verificadores de CPF (Cadastro de Pessoa Física).

## Recursos

- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings
- ✅ **Agnóstico ao formato**: Remove caracteres não numéricos da entrada em string
- ✅ **Junção em array**: Strings com vários caracteres em arrays são concatenadas e interpretadas como uma única sequência
- ✅ **Validação de entrada**: Rejeita CPFs inelegíveis (9 dígitos idênticos na base — padrão de repetição)
- ✅ **Avaliação lazy**: Dígitos verificadores são calculados apenas quando acessados (via métodos)
- ✅ **Cache**: Valores calculados são armazenados em cache para acessos subsequentes
- ✅ **Dependências mínimas**: Apenas [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Erros de uso da API vs erros de domínio, com o marcador `CpfDV::Error` para resgate em nível de biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cpf-dv
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cpf-dv'
```

## Require

```ruby
require 'cpf-dv'
```

## Início rápido

```ruby
require 'cpf-dv'

check_digits = CpfDV::CpfCheckDigits.new('054496519')

check_digits.first    # => '1'
check_digits.second   # => '0'
check_digits.both     # => '10'
check_digits.cpf      # => '05449651910'
```

## Utilização

O principal recurso deste pacote é a classe `CpfDV::CpfCheckDigits`. Por meio da instância, você acessa as informações dos dígitos verificadores do CPF:

- **`initialize`**: `CpfDV::CpfCheckDigits.new(cpf_input)` — `cpf_input` deve ser `String` ou `Array` de strings. Após a sanitização, o valor deve ter 9–11 dígitos (formatação removida em strings). Apenas os **primeiros 9** dígitos entram como base; com 10 ou 11 dígitos (ex.: CPF completo com DV anteriores), os dígitos 10 e 11 são **ignorados** e os dígitos verificadores são recalculados. Não há **opções**, argumentos nomeados nem objeto de configuração — o construtor recebe apenas a entrada de CPF.
- **`first`**: Primeiro dígito verificador (10º dígito do CPF completo). Lazy, em cache.
- **`second`**: Segundo dígito verificador (11º dígito do CPF completo). Lazy, em cache.
- **`both`**: Ambos os dígitos verificadores concatenados em uma string.
- **`cpf`**: O CPF completo como string de 11 dígitos (9 da base + 2 dígitos verificadores).

### Formatos de entrada

A classe `CpfCheckDigits` aceita múltiplos formatos de entrada:

**String:** dígitos crus ou CPF formatado (ex.: `054.496.519-10`, `123.456.789`). Caracteres não numéricos são removidos. Zeros à esquerda são preservados.

**Array de strings:** cada elemento deve ser string; os valores são concatenados e interpretados como uma única string (ex.: `['0','5','4',…]`, `['054','496','519']`, `['054496519']`). Elementos que não são strings não são permitidos.

```ruby
require 'cpf-dv'

# String — crua, formatada ou com DV existentes (apenas os 9 primeiros dígitos são usados)
CpfDV::CpfCheckDigits.new('054496519')
CpfDV::CpfCheckDigits.new('054.496.519-10')
CpfDV::CpfCheckDigits.new('05449651910')

# Array de strings — elementos de um ou vários caracteres
CpfDV::CpfCheckDigits.new(%w[0 5 4 4 9 6 5 1 9])
CpfDV::CpfCheckDigits.new(%w[054 496 519])
CpfDV::CpfCheckDigits.new(%w[054496519])
```

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado). Detectável pela forma da chamada. |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (tamanho, elegibilidade). |

Todo erro customizado inclui o módulo marcador `CpfDV::Error`. Falhas de domínio (`InvalidLengthError`, `ValidationError`) herdam de `CpfDV::DomainError` (`RangeError`).

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CpfDV::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Argumento com tipo de dado incorreto |
| `CpfDV::InvalidLengthError` | `CpfDV::DomainError` | Erro de domínio | Tamanho após sanitização não é 9–11 |
| `CpfDV::ValidationError` | `CpfDV::DomainError` | Erro de domínio | Os 9 primeiros dígitos são todos idênticos (padrão de repetição) |

#### `CpfDV::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CpfDV::Error
  # tudo o que esta biblioteca levanta
```

#### `CpfDV::DomainError`

- **Herança:** `CpfDV::DomainError < RangeError` (inclui `CpfDV::Error`)
- **Categoria:** Erro de domínio — ancestral das falhas numéricas/de tamanho.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CpfDV::InvalidLengthError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CpfDV::DomainError
  # InvalidLengthError, ValidationError e qualquer outra subclasse de DomainError
```

#### `CpfDV::TypeMismatchError`

- **Herança:** `CpfDV::TypeMismatchError < TypeError` (inclui `CpfDV::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada de CPF não é `String` nem `Array` de strings (ou o array contém elemento que não é string).
- **Exemplo:**

```ruby
CpfDV::CpfCheckDigits.new(12_345_678_901)   # levanta CpfDV::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CpfDV::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CpfDV::InvalidLengthError`

- **Herança:** `CpfDV::InvalidLengthError < CpfDV::DomainError < RangeError` (inclui `CpfDV::Error`)
- **Categoria:** Erro de domínio — o tamanho de uma coleção ou string viola uma regra de negócio.
- **Quando é levantado:** Levantado quando a entrada de CPF sanitizada não contém de 9 a 11 dígitos.
- **Exemplo:**

```ruby
CpfDV::CpfCheckDigits.new('12345678')   # levanta CpfDV::InvalidLengthError
```

- **Como resgatar:**

```ruby
rescue CpfDV::InvalidLengthError
  # esta violação exata de tamanho

rescue CpfDV::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CpfDV::ValidationError`

- **Herança:** `CpfDV::ValidationError < CpfDV::DomainError < RangeError` (inclui `CpfDV::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando os 9 primeiros dígitos são o mesmo dígito (padrão de repetição).
- **Exemplo:**

```ruby
CpfDV::CpfCheckDigits.new('111111111')   # levanta CpfDV::ValidationError
```

- **Como resgatar:**

```ruby
rescue CpfDV::ValidationError
  # esta falha exata de validação de domínio

rescue CpfDV::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Uma classe nativa — captura uso incorreto de tipo desta biblioteca (e outros TypeError).
rescue TypeError
  # CpfDV::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CpfDV::DomainError — captura violações de regra de negócio sob DomainError.
rescue CpfDV::DomainError
  # CpfDV::InvalidLengthError, CpfDV::ValidationError e outras subclasses de DomainError

# 3) CpfDV::Error — captura tudo o que a biblioteca levanta.
rescue CpfDV::Error
  # todo erro customizado que inclui CpfDV::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CpfDV::InvalidLengthError
  # apenas CpfDV::InvalidLengthError
```

Atributos relevantes nos erros:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `min_expected_length`, `max_expected_length`
- `ValidationError`: `actual_input`, `reason`

### Outros recursos disponíveis

Após `require 'cpf-dv'`:

- **`CpfDV::CPF_MIN_LENGTH`**: `9`
- **`CpfDV::CPF_MAX_LENGTH`**: `11`
- **Erros**: veja acima (`CpfDV::Error`, `DomainError` e folhas levantadas)

## Algoritmo de cálculo

O pacote calcula os dígitos verificadores do CPF usando o algoritmo oficial brasileiro de módulo 11:

1. **Primeiro dígito verificador (10ª posição):** aplicar aos **primeiros 9** dígitos da base; pesos **10, 9, 8, 7, 6, 5, 4, 3, 2** (da esquerda para a direita); seja `resto = 11 - (soma(dígito × peso) % 11)`. O dígito é `0` se `resto > 9`, senão `resto`.
2. **Segundo dígito verificador (11ª posição):** aplicar aos 9 dígitos da base **mais** o primeiro dígito verificador; pesos **11, 10, 9, 8, 7, 6, 5, 4, 3, 2** (da esquerda para a direita); mesma fórmula para `resto`.

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
