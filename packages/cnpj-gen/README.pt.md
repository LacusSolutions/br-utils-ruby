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
- ✅ **Tratamento de erros**: Erros de tipo e exceções específicas para opções inválidas

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
| `format` | `Boolean`, `nil` | `false` | Se truthy, retorna o CNPJ gerado no formato padrão (`00.000.000/0000-00`). Valores não booleanos são convertidos (`false`, `''` e `0` viram `false`; demais valores viram truthy). |
| `prefix` | `String`, `nil` | `''` | String inicial parcial (0–12 caracteres alfanuméricos). Apenas alfanuméricos são mantidos e convertidos para maiúsculas; os caracteres faltantes são gerados aleatoriamente e os dígitos verificadores são calculados. |
| `type` | `String`, `nil` | `'alphanumeric'` | Conjunto de caracteres da parte gerada aleatoriamente (o `prefix` é mantido após sanitização). Deve ser um de `'numeric'`, `'alphabetic'` ou `'alphanumeric'`. **Os dígitos verificadores são sempre numéricos.** |

Regras do prefixo: a base (primeiros 8 caracteres) e a filial (caracteres 9–12) não podem ser todos zeros; 12 dígitos repetidos (ex.: `777777777777`) também não são permitidos.

### `CnpjGen.cnpj_gen` (helper)

Gera uma string de CNPJ válida. Sem opções, retorna um CNPJ alfanumérico de 14 caracteres. É um atalho para `CnpjGen::CnpjGenerator.new(...).generate`.

- **`options`** (opcional): instância de `CnpjGen::CnpjGeneratorOptions`, `Hash` de chaves de opção ou `nil`. Veja [Opções do gerador](#opções-do-gerador).
- **`format`**, **`prefix`**, **`type`** (argumentos nomeados): Sobrescritas por opção quando `options` é omitido ou para compor sobre um `Hash`.

### `CnpjGen::CnpjGenerator` (classe)

Para padrões reutilizáveis ou sobrescritas por chamada, use a classe:

```ruby
require 'cnpj-gen'

generator = CnpjGen::CnpjGenerator.new(type: 'numeric', format: true)

generator.generate                    # => ex.: "73.008.535/0005-06"
generator.generate(prefix: '12345678')   # sobrescrita apenas nesta chamada
generator.options                     # opções padrão atuais (CnpjGen::CnpjGeneratorOptions)
```

- **`initialize(options = nil, format: nil, prefix: nil, type: nil)`**: Opções padrão opcionais (`Hash` simples, instância de `CnpjGen::CnpjGeneratorOptions` ou argumentos nomeados). Quando `options` é uma instância de `CnpjGen::CnpjGeneratorOptions`, essa instância é armazenada (mutações posteriores afetam futuras chamadas de `generate` que não passarem opções por chamada).
- **`generate(options = nil, format: nil, prefix: nil, type: nil)`**: Retorna um CNPJ válido; opções por chamada sobrescrevem os padrões da instância apenas naquela chamada.
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
```

- **`initialize(options = nil, *extra_overrides, format: nil, prefix: nil, type: nil)`**: Opções mescladas em ordem (as últimas sobrescritas prevalecem). Argumentos posicionais extras podem ser `Hash` ou outras instâncias de `CnpjGen::CnpjGeneratorOptions`.
- **`format`**, **`prefix`**, **`type`**: Acessores com setters; `prefix` é validado (base/filial inelegíveis, dígitos repetidos).
- **`set(options)`**: Atualiza várias opções de uma vez; campos omitidos/`nil` em um `Hash` mantêm o valor atual; retorna `self`. Aceita `Hash` ou outra instância de `CnpjGen::CnpjGeneratorOptions`.
- **`all`**: Cópia superficial em `Hash` das opções atuais (`:format`, `:prefix`, `:type`).

## API

### Exportações

Após `require 'cnpj-gen'`:

- **`CnpjGen.cnpj_gen`**: `(options = nil, format: nil, prefix: nil, type: nil) -> String` — helper de conveniência.
- **`CnpjGen::CnpjGenerator`**: Classe para gerar CNPJ com opções padrão e sobrescritas por chamada.
- **`CnpjGen::CnpjGeneratorOptions`**: Classe que armazena opções com validação e mesclagem.
- **`CnpjGen::CNPJ_LENGTH`**: `14` (constante).
- **`CnpjGen::CNPJ_PREFIX_MAX_LENGTH`**: `12` (constante).
- **`CnpjGen::CNPJ_TYPE_VALUES`**: `%w[alphabetic alphanumeric numeric]` — valores permitidos para `type`.
- **`CnpjGen::VERSION`**: string da versão da gem.
- **Exceções**: `CnpjGen::CnpjGeneratorTypeError`, `CnpjGen::CnpjGeneratorOptionsTypeError`, `CnpjGen::CnpjGeneratorException`, `CnpjGen::CnpjGeneratorOptionPrefixInvalidException`, `CnpjGen::CnpjGeneratorOptionTypeInvalidException`.

### Erros e exceções

Este pacote usa subclasses de **TypeError** para tipos de opção inválidos e subclasses de **StandardError** para valores de opção inválidos (`prefix` ou `type`). Você pode capturar classes específicas ou os tipos base.

- **CnpjGen::CnpjGeneratorTypeError** — base para erros de tipo de opção (abstrata; capture subclasses)
- **CnpjGen::CnpjGeneratorOptionsTypeError** — uma opção tem o tipo errado (ex.: `prefix` não é `String`)
- **CnpjGen::CnpjGeneratorException** — base para exceções de valor de opção
- **CnpjGen::CnpjGeneratorOptionPrefixInvalidException** — prefixo inválido (ex.: base/filial zerada, dígitos repetidos)
- **CnpjGen::CnpjGeneratorOptionTypeInvalidException** — `type` não é um de `'numeric'`, `'alphabetic'`, `'alphanumeric'`

```ruby
require 'cnpj-gen'

# Tipo de opção (ex.: `prefix` deve ser String)
begin
  CnpjGen.cnpj_gen(prefix: 123)
rescue CnpjGen::CnpjGeneratorOptionsTypeError => e
  puts e.option_name, e.expected_type, e.actual_type
  # CNPJ generator option "prefix" must be of type string. Got integer number.
end

# Prefixo inválido (ex.: base zerada)
begin
  CnpjGen.cnpj_gen(prefix: '000000000001')
rescue CnpjGen::CnpjGeneratorOptionPrefixInvalidException => e
  puts e.reason, e.actual_input
end

# Valor de type inválido
begin
  CnpjGen.cnpj_gen(type: 'invalid')
rescue CnpjGen::CnpjGeneratorOptionTypeInvalidException => e
  puts e.expected_values, e.actual_input
end

# Qualquer exceção do pacote
begin
  CnpjGen.cnpj_gen(prefix: '000000000000')
rescue CnpjGen::CnpjGeneratorException => e
  puts e.message
end
```

Atributos relevantes nos erros lançados:

- `CnpjGeneratorOptionsTypeError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `CnpjGeneratorOptionPrefixInvalidException`: `actual_input`, `reason`
- `CnpjGeneratorOptionTypeInvalidException`: `actual_input`, `expected_values`

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
