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
- ✅ **Tratamento de erros**: Tipos específicos para tipo, tamanho e CNPJ inválido (semântica `TypeError` vs `StandardError`)

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

### Erros e exceções

Este pacote usa a distinção **TypeError vs StandardError**: *erros de tipo* indicam uso incorreto da API (ex.: tipo errado); *exceções* indicam dados inválidos ou inelegíveis (ex.: tamanho ou regras de negócio). Você pode resgatar classes específicas ou as classes base.

- **`CnpjDV::CnpjCheckDigitsTypeError`** — classe base para erros de tipo; estende o `TypeError` do Ruby
- **`CnpjDV::CnpjCheckDigitsInputTypeError`** — entrada não é `String` nem `Array` de strings (ou o array contém elemento que não é string)
- **`CnpjDV::CnpjCheckDigitsException`** — classe base para exceções de dados/fluxo; estende `StandardError`
- **`CnpjDV::CnpjCheckDigitsInputLengthException`** — tamanho após sanitização não é 12–14
- **`CnpjDV::CnpjCheckDigitsInputInvalidException`** — base `00000000`, filial `0000`, ou 12 dígitos numéricos idênticos (padrão de repetição)

```ruby
require 'cnpj-dv'

# Tipo de entrada (ex.: inteiro não permitido)
begin
  CnpjDV::CnpjCheckDigits.new(12_345_678_000_100)
rescue CnpjDV::CnpjCheckDigitsInputTypeError => e
  puts e.message
  # => CNPJ input must be of type string or string[]. Got integer number.
end

# Tamanho (deve ser 12–14 caracteres alfanuméricos após sanitização)
begin
  CnpjDV::CnpjCheckDigits.new('12345678901')
rescue CnpjDV::CnpjCheckDigitsInputLengthException => e
  puts e.message
  # => CNPJ input "12345678901" does not contain 12 to 14 characters. Got 11.
end

# Inválido (ex.: base ou filial zeradas, ou dígitos numéricos repetidos)
begin
  CnpjDV::CnpjCheckDigits.new('000000000001')
rescue CnpjDV::CnpjCheckDigitsInputInvalidException => e
  puts e.message
  # => CNPJ input "000000000001" is invalid. Base ID "00000000" is not eligible.
end

# Qualquer exceção de dados do pacote
begin
  CnpjDV::CnpjCheckDigits.new('000000000001')
rescue CnpjDV::CnpjCheckDigitsException => e
  puts e.message
end
```

Atributos relevantes nos erros:

- `CnpjCheckDigitsInputTypeError`: `actual_input`, `actual_type`, `expected_type`
- `CnpjCheckDigitsInputLengthException`: `actual_input`, `evaluated_input`, `min_expected_length`, `max_expected_length`
- `CnpjCheckDigitsInputInvalidException`: `actual_input`, `reason`

### Outros recursos disponíveis

Após `require 'cnpj-dv'`:

- **`CnpjDV::CNPJ_MIN_LENGTH`**: `12`
- **`CnpjDV::CNPJ_MAX_LENGTH`**: `14`
- **Exceções**: veja acima

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
