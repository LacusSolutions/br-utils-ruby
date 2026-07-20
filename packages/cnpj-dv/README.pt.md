![cnpj-dv para Ruby](https://br-utils.vercel.app/img/cover_cnpj-dv.jpg)

> 🚀 **Suporte total ao [novo formato alfanumérico de CNPJ](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Access documentation in English](https://github.com/LacusSolutions/br-utils-ruby/blob/main/packages/cnpj-dv/README.md)

Utilitário em Ruby para calcular os dígitos verificadores de CNPJ (Cadastro Nacional da Pessoa Jurídica).

## Recursos

- ✅ **CNPJ alfanumérico**: Suporte completo ao novo formato alfanumérico de CNPJ (a partir de 2026)
- ✅ **Entrada flexível**: Aceita `String` ou `Array` de strings
- ✅ **Agnóstico ao formato**: Remove caracteres não alfanuméricos da entrada em string e converte letras para maiúsculas
- ✅ **Junção em array**: Strings com vários caracteres em arrays são concatenadas e interpretadas como uma única sequência
- ✅ **Validação de entrada**: Rejeita CNPJs inelegíveis (base toda zero `00000000`, filial `0000`, ou 12 dígitos numéricos repetidos)
- ✅ **Avaliação lazy**: Dígitos verificadores são calculados apenas quando acessados (via métodos)
- ✅ **Cache**: Valores calculados são armazenados em cache para acessos subsequentes
- ✅ **Dependências mínimas**: Apenas [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Erros de uso da API vs erros de domínio, com o marcador `CnpjDV::Error` para resgate em nível de biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cnpj-dv
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cnpj-dv'
```

## Require

```ruby
require 'cnpj-dv'
```

## Início rápido

```ruby
require 'cnpj-dv'

check_digits = CnpjDV::CnpjCheckDigits.new('914157320007')

check_digits.first   # => '9'
check_digits.second  # => '3'
check_digits.both    # => '93'
check_digits.cnpj    # => '91415732000793'
```

Com CNPJ alfanumérico (novo formato):

```ruby
require 'cnpj-dv'

check_digits = CnpjDV::CnpjCheckDigits.new('MGKGMJ9X0001')

check_digits.first   # => '6'
check_digits.second  # => '8'
check_digits.both    # => '68'
check_digits.cnpj    # => 'MGKGMJ9X000168'
```

## Utilização

O principal recurso deste pacote é a classe `CnpjDV::CnpjCheckDigits`. Por meio da instância, você acessa as informações dos dígitos verificadores do CNPJ:

- **`initialize`**: `CnpjDV::CnpjCheckDigits.new(cnpj_input)` — `cnpj_input` deve ser `String` ou `Array` de strings. Após a sanitização, o valor deve ter 12–14 caracteres alfanuméricos (formatação removida em strings; letras em maiúsculas). Apenas os **primeiros 12** caracteres entram como base; com 13 ou 14 caracteres (ex.: CNPJ completo com DV anteriores), os caracteres 13 e 14 são **ignorados** e os dígitos são recalculados. Não há **opções**, argumentos nomeados nem objeto de configuração — o construtor recebe apenas a entrada de CNPJ.
- **`first`**: Primeiro dígito verificador (13º caractere do CNPJ completo). Lazy, em cache.
- **`second`**: Segundo dígito verificador (14º caractere do CNPJ completo). Lazy, em cache.
- **`both`**: Ambos os dígitos verificadores concatenados em uma string.
- **`cnpj`**: O CNPJ completo como string de 14 caracteres (12 da base + 2 dígitos verificadores).

### Formatos de entrada

A classe `CnpjCheckDigits` aceita múltiplos formatos de entrada:

**String:** dígitos e/ou letras crus, ou CNPJ formatado (ex.: `91.415.732/0007-93`, `MG.KGM.J9X/0001-68`). Caracteres não alfanuméricos são removidos; letras minúsculas viram maiúsculas.

**Array de strings:** cada elemento deve ser string; os valores são concatenados e interpretados como uma única string (ex.: `['9','1','4',…]`, `['9141','5732','0007']`, `['MG','KGM','J9X','0001']`). Elementos que não são strings não são permitidos.

```ruby
require 'cnpj-dv'

# String — crua, formatada ou com DV existentes (apenas os 12 primeiros caracteres são usados)
CnpjDV::CnpjCheckDigits.new('914157320007')
CnpjDV::CnpjCheckDigits.new('91.415.732/0007')
CnpjDV::CnpjCheckDigits.new('91415732000793')

# Array de strings — elementos de um ou vários caracteres
CnpjDV::CnpjCheckDigits.new(%w[9 1 4 1 5 7 3 2 0 0 0 7])
CnpjDV::CnpjCheckDigits.new(%w[9141 5732 0007])
CnpjDV::CnpjCheckDigits.new(%w[MG KGM J9X 0001])
```

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado). Detectável pela forma da chamada. |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (tamanho, elegibilidade, formato). |

Todo erro customizado inclui o módulo marcador `CnpjDV::Error`. Falhas de domínio (`InvalidLengthError`, `ValidationError`) herdam de `CnpjDV::DomainError` (`RangeError`).

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CnpjDV::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Argumento com tipo de dado incorreto |
| `CnpjDV::InvalidLengthError` | `CnpjDV::DomainError` | Erro de domínio | Tamanho após sanitização não é 12–14 |
| `CnpjDV::ValidationError` | `CnpjDV::DomainError` | Erro de domínio | Base/filial inelegível ou dígitos numéricos repetidos |

#### `CnpjDV::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CnpjDV::Error
  # tudo o que esta biblioteca levanta
```

#### `CnpjDV::DomainError`

- **Herança:** `CnpjDV::DomainError < RangeError` (inclui `CnpjDV::Error`)
- **Categoria:** Erro de domínio — ancestral das falhas numéricas/de tamanho.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CnpjDV::InvalidLengthError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CnpjDV::DomainError
  # InvalidLengthError, ValidationError e qualquer outra subclasse de DomainError
```

#### `CnpjDV::TypeMismatchError`

- **Herança:** `CnpjDV::TypeMismatchError < TypeError` (inclui `CnpjDV::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando a entrada de CNPJ não é `String` nem `Array` de strings (ou o array contém elemento que não é string).
- **Exemplo:**

```ruby
CnpjDV::CnpjCheckDigits.new(12_345_678_000_100) # levanta CnpjDV::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CnpjDV::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CnpjDV::InvalidLengthError`

- **Herança:** `CnpjDV::InvalidLengthError < CnpjDV::DomainError < RangeError` (inclui `CnpjDV::Error`)
- **Categoria:** Erro de domínio — o tamanho de uma coleção ou string viola uma regra de negócio.
- **Quando é levantado:** Levantado quando a entrada de CNPJ sanitizada não contém de 12 a 14 caracteres alfanuméricos.
- **Exemplo:**

```ruby
CnpjDV::CnpjCheckDigits.new('12345678901') # levanta CnpjDV::InvalidLengthError
```

- **Como resgatar:**

```ruby
rescue CnpjDV::InvalidLengthError
  # esta violação exata de tamanho

rescue CnpjDV::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### `CnpjDV::ValidationError`

- **Herança:** `CnpjDV::ValidationError < CnpjDV::DomainError < RangeError` (inclui `CnpjDV::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando a base é `00000000`, a filial é `0000`, ou os 12 primeiros caracteres são o mesmo dígito numérico.
- **Exemplo:**

```ruby
CnpjDV::CnpjCheckDigits.new('000000000001') # levanta CnpjDV::ValidationError
```

- **Como resgatar:**

```ruby
rescue CnpjDV::ValidationError
  # esta falha exata de validação de domínio

rescue CnpjDV::DomainError
  # falhas de domínio enraizadas em RangeError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Uma classe nativa — captura uso incorreto de tipo desta biblioteca (e outros TypeError).
rescue TypeError
  # CnpjDV::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CnpjDV::DomainError — captura violações de regra de negócio sob DomainError.
rescue CnpjDV::DomainError
  # CnpjDV::InvalidLengthError, CnpjDV::ValidationError e outras subclasses de DomainError

# 3) CnpjDV::Error — captura tudo o que a biblioteca levanta.
rescue CnpjDV::Error
  # todo erro customizado que inclui CnpjDV::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CnpjDV::InvalidLengthError
  # apenas CnpjDV::InvalidLengthError
```

Atributos relevantes nos erros:

- `TypeMismatchError`: `actual_input`, `actual_type`, `expected_type`
- `InvalidLengthError`: `actual_input`, `evaluated_input`, `min_expected_length`, `max_expected_length`
- `ValidationError`: `actual_input`, `reason`

### Outros recursos disponíveis

Após `require 'cnpj-dv'`:

- **`CnpjDV::CNPJ_MIN_LENGTH`**: `12`
- **`CnpjDV::CNPJ_MAX_LENGTH`**: `14`
- **Erros**: veja acima (`CnpjDV::Error`, `DomainError` e folhas levantadas)

## Algoritmo de cálculo

O pacote calcula os dígitos verificadores com as regras oficiais brasileiras de módulo 11 estendidas a caracteres alfanuméricos:

1. **Valor do caractere:** cada caractere contribui com `ord(caractere) − 48` (assim `0`–`9` permanecem 0–9; letras usam o deslocamento ASCII em relação a `0`).
2. **Pesos:** da **direita para a esquerda**, multiplicar pelos pesos que ciclam **2, 3, 4, 5, 6, 7, 8, 9** e voltam a 2.
3. **Primeiro dígito verificador (13ª posição):** aplicar os itens 1–2 aos **primeiros 12** caracteres da base; seja `r = soma % 11`. O dígito é `0` se `r < 2`, senão `11 − r`.
4. **Segundo dígito verificador (14ª posição):** aplicar os itens 1–2 aos 12 primeiros caracteres **mais** o primeiro dígito verificador; mesma fórmula para `r`.

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
