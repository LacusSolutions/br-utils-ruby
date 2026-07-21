![cpf-gen para Ruby](https://br-utils.vercel.app/img/cover_cpf-gen.jpg)

> 🌎 [Access documentation in English](./README.md)

Utilitário em Ruby para gerar CPFs válidos (Cadastro de Pessoa Física).

## Recursos

- ✅ **CPF numérico**: Gera CPF de 11 dígitos numéricos com dígitos verificadores válidos
- ✅ **Prefixo opcional**: Informe de 0 a 9 dígitos para fixar o início do CPF e gerar o restante com dígitos verificadores válidos
- ✅ **Formatação**: Opção de retornar a string no formato padrão (`000.000.000-00`)
- ✅ **Gerador reutilizável**: Classe `CpfGen::CpfGenerator` com opções padrão e sobrescritas por chamada
- ✅ **Sobrescritas por palavra-chave**: Passe `format:` e `prefix:` em `cpf_gen`, `CpfGenerator#generate` e nos construtores
- ✅ **Dependências mínimas**: Apenas [`cpf-dv`](https://rubygems.org/gems/cpf-dv) e [`lacus-utils`](https://rubygems.org/gems/lacus-utils)
- ✅ **Tratamento de erros**: Uso incorreto da API vs erros de domínio, com marcador `CpfGen::Error` para captura em toda a biblioteca

## Instalação

Instale a gem diretamente:

```bash
gem install cpf-gen
```

Ou adicione ao seu `Gemfile` e execute `bundle install`:

```ruby
gem 'cpf-gen'
```

## Require

```ruby
require 'cpf-gen'
```

## Início rápido

```ruby
require 'cpf-gen'

CpfGen.cpf_gen                    # => ex.: "47844241055" (11 dígitos numéricos)

CpfGen.cpf_gen(format: true)      # => ex.: "005.265.352-88"

CpfGen.cpf_gen(prefix: '528250911')           # => ex.: "52825091138"
CpfGen.cpf_gen(                              # => ex.: "528.250.911-38"
  prefix: '528250911',
  format: true
)
```

As opções também podem ser passadas como `Hash`:

```ruby
CpfGen.cpf_gen({ format: true, prefix: '528250911' })
```

## Utilização

Os pontos principais são o helper de módulo `CpfGen.cpf_gen`, a classe `CpfGen::CpfGenerator` e a classe de opções `CpfGen::CpfGeneratorOptions`.

### Opções do gerador

Todas as opções são opcionais:

| Opção | Tipo | Padrão | Descrição |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | Se truthy, retorna o CPF gerado no formato padrão (`000.000.000-00`). Valores não booleanos são convertidos (`false`, `''` e `0` viram `false`; demais valores viram truthy). |
| `prefix` | `String` | `''` | String inicial parcial (0–9 dígitos). Apenas dígitos são mantidos; os caracteres faltantes são gerados aleatoriamente e os dígitos verificadores são calculados. Prefixos com mais de 9 dígitos são truncados silenciosamente. |

Regras do prefixo: a base (primeiros 9 dígitos) não pode ser toda zerada; 9 dígitos repetidos (ex.: `999999999`) não são permitidos. Prefixos com menos de 9 dígitos nunca são rejeitados por essas regras (ex.: `"00000000"` e `"11111111"` são permitidos).

`nil` é aceito como argumento nomeado em `cpf_gen`, `CpfGenerator.new`, `CpfGenerator#generate` e `CpfGeneratorOptions.new`/`#set` — significa apenas "sem sobrescrita para esta opção". **Não** é aceito pelos setters de propriedade de `CpfGeneratorOptions` (`options.format = valor`, `options.prefix = valor`): chamar um setter com `nil` diretamente lança `CpfGen::TypeMismatchError`. Para redefinir uma propriedade ao seu valor padrão via setter, passe a constante literal, ex.: `options.format = CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT`.

### `CpfGen.cpf_gen` (helper)

Gera uma string de CPF válida. Sem opções, retorna um CPF numérico de 11 dígitos. É um atalho para `CpfGen::CpfGenerator.new(...).generate`.

- **`options`** (opcional): instância de `CpfGen::CpfGeneratorOptions`, `Hash` de chaves de opção ou `nil`. Veja [Opções do gerador](#opções-do-gerador).
- **`format`**, **`prefix`** (argumentos nomeados): Usados apenas quando `options` é omitido (`nil`). Passar `options` **e** qualquer um desses argumentos nomeados não-`nil` ao mesmo tempo gera `InvalidArgumentCombinationError` — as duas formas de passar opções nunca são mescladas entre si.

### `CpfGen::CpfGenerator` (classe)

Para padrões reutilizáveis ou sobrescritas por chamada, use a classe:

```ruby
require 'cpf-gen'

generator = CpfGen::CpfGenerator.new(format: true)

generator.generate                    # => ex.: "005.265.352-88"
generator.generate(prefix: '123456')  # sobrescrita apenas nesta chamada
generator.options                     # opções padrão atuais (CpfGen::CpfGeneratorOptions)
```

- **`initialize(options = nil, **keywords)`**: Opções padrão opcionais. Quando `options` é fornecido isoladamente (instância de `CpfGen::CpfGeneratorOptions` ou `Hash`), ele determina as opções padrão; uma instância de `CpfGen::CpfGeneratorOptions` é armazenada por referência (mutações posteriores afetam futuras chamadas de `generate` que não passarem opções por chamada), enquanto um `Hash` cria uma nova instância. Quando `options` é omitido (`nil`), as opções padrão são construídas exclusivamente a partir dos argumentos nomeados (`format:`, `prefix:`). Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`, em vez de ignorar os argumentos nomeados silenciosamente.
- **`generate(options = nil, **keywords)`**: Retorna um CPF válido. `options` e os argumentos nomeados nunca são mesclados: um `options` fornecido isoladamente sobrescreve totalmente os padrões da instância nesta chamada; caso contrário, qualquer argumento nomeado fornecido sobrescreve os padrões da instância nesta chamada. Quando nenhum dos dois é fornecido, os padrões da instância são usados como estão. Os padrões da instância nunca são alterados por uma sobrescrita pontual. Passar `options` junto com qualquer argumento nomeado não `nil` gera `InvalidArgumentCombinationError`.
- **`options`**: Reader que retorna as opções padrão usadas quando não há opções por chamada (mesma instância usada internamente; mutá-la afeta futuras chamadas de `generate`).

Opções padrão na instância; sobrescritas por chamada:

```ruby
require 'cpf-gen'

generator = CpfGen::CpfGenerator.new(format: true)

generator.generate              # CPF formatado
generator.generate(format: false)  # somente nesta chamada: sem formato
generator.generate              # volta ao padrão da instância
```

### `CpfGen::CpfGeneratorOptions` (classe)

Armazena opções (`format`, `prefix`) com validação e suporte a mesclagem:

```ruby
require 'cpf-gen'

options = CpfGen::CpfGeneratorOptions.new(
  prefix: '123456',
  format: true
)
options.prefix   # => "123456"
options.format   # => true
options.set(format: false)  # mescla e retorna self
options.all      # => { format: false, prefix: "123456" }

# Redefinir uma propriedade ao seu valor padrão exige a constante literal —
# um `nil` direto no setter lança TypeMismatchError:
options.format = CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT
```

- **`initialize(*options, **keywords)`**: Cada argumento posicional `options` (um `Hash` ou outra instância de `CpfGen::CpfGeneratorOptions`) é combinado da esquerda para a direita — os últimos prevalecem — e então os argumentos nomeados (`format:`, `prefix:`) são aplicados por cima com a maior precedência. Em cada etapa, um valor `nil` para uma dada chave é ignorado em favor do que já foi resolvido. Qualquer opção ainda não resolvida recebe seu valor `DEFAULT_*`.
- **`format`**, **`prefix`**: Acessores com setters; `prefix` é validado (base zerada, dígitos repetidos). Os setters **nunca aceitam `nil`** — passe a constante `DEFAULT_*` correspondente (ex.: `CpfGeneratorOptions::DEFAULT_PREFIX`) para redefinir uma propriedade explicitamente.
- **`set(*options, **keywords)`**: Atualiza várias opções de uma vez, usando a mesma resolução de `initialize` (combinação seguida de argumentos nomeados, ignorando `nil`). Qualquer opção não resolvida após a combinação mantém seu valor **atual** na instância (uma atualização parcial, não uma reinicialização). Retorna `self`.
- **`all`**: Cópia superficial em `Hash` das opções atuais (`:format`, `:prefix`).

## API

### Exportações

Após `require 'cpf-gen'`:

- **`CpfGen.cpf_gen`**: `(options = nil, **keywords) -> String` — helper de conveniência.
- **`CpfGen::CpfGenerator`**: Classe para gerar CPF com opções padrão e sobrescritas por chamada.
- **`CpfGen::CpfGeneratorOptions`**: Classe que armazena opções com validação e mesclagem.
- **`CpfGen::CPF_LENGTH`**: `11` (constante).
- **`CpfGen::CPF_PREFIX_MAX_LENGTH`**: `9` (constante).
- **`CpfGen::VERSION`**: string da versão da gem.
- **Erros**: `CpfGen::Error`, `CpfGen::DomainError`, `CpfGen::InvalidArgumentCombinationError`, `CpfGen::TypeMismatchError`, `CpfGen::ValidationError`.

### Tratamento de erros

Os erros se dividem em duas categorias:

| Categoria | Significado |
|---|---|
| **Uso incorreto da API** | O chamador usou a biblioteca de forma incorreta (tipo errado para uma opção, ou combinação inválida de argumentos). |
| **Erro de domínio** | A chamada estava estruturalmente correta, mas um valor viola uma regra de negócio (`prefix` inválido). |

Todo erro customizado inclui o módulo marcador `CpfGen::Error`. Falhas de domínio (`ValidationError`) herdam de `CpfGen::DomainError` (`RangeError`).

**Importante:** passar ao mesmo tempo uma instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` levanta `InvalidArgumentCombinationError`.

#### Resumo

| Classe | Herda de | Categoria | Condição de disparo |
|---|---|---|---|
| `CpfGen::InvalidArgumentCombinationError` | `ArgumentError` (+ `include Error`) | Uso incorreto da API | Instância/`Hash` de `options` e qualquer argumento nomeado não-`nil` passados ao mesmo tempo |
| `CpfGen::TypeMismatchError` | `TypeError` (+ `include Error`) | Uso incorreto da API | Uma opção do gerador tem o tipo de dado incorreto |
| `CpfGen::ValidationError` | `CpfGen::DomainError` | Erro de domínio | `prefix` inelegível (base zerada ou 9 dígitos repetidos) |

#### `CpfGen::Error` (módulo marcador)

- **Herança:** módulo marcador misturado em todo erro da biblioteca via `include` (não é uma classe).
- **Categoria:** N/A (apenas alvo de `rescue`) — não é um modo de falha por si só.
- **Quando é levantado:** Nunca diretamente; incluído por todo erro customizado que a biblioteca levanta.
- **Exemplo:** N/A
- **Como resgatar:**

```ruby
rescue CpfGen::Error
  # tudo o que esta biblioteca levanta
```

#### `CpfGen::DomainError`

- **Herança:** `CpfGen::DomainError < RangeError` (inclui `CpfGen::Error`)
- **Categoria:** Erro de domínio — ancestral de todas as falhas de domínio.
- **Quando é levantado:** Não é levantado diretamente; prefira uma subclasse folha.
- **Exemplo:** Prefira `raise CpfGen::ValidationError` a levantar `DomainError` diretamente.
- **Como resgatar:**

```ruby
rescue CpfGen::DomainError
  # ValidationError e outras subclasses de DomainError
```

#### `CpfGen::TypeMismatchError`

- **Herança:** `CpfGen::TypeMismatchError < TypeError` (inclui `CpfGen::Error`)
- **Categoria:** Uso incorreto da API — o chamador passou um valor do tipo errado.
- **Quando é levantado:** Levantado quando uma opção do gerador (`format` ou `prefix`) tem o tipo de runtime incorreto.
- **Exemplo:**

```ruby
CpfGen.cpf_gen(prefix: 123) # levanta CpfGen::TypeMismatchError
```

- **Como resgatar:**

```ruby
rescue CpfGen::TypeMismatchError
  # violação de contrato de tipo desta biblioteca

rescue TypeError
  # erros nativos de tipo, incluindo TypeMismatchError desta biblioteca
```

#### `CpfGen::InvalidArgumentCombinationError`

- **Herança:** `CpfGen::InvalidArgumentCombinationError < ArgumentError` (inclui `CpfGen::Error`)
- **Categoria:** Uso incorreto da API — o chamador misturou padrões de argumentos mutuamente exclusivos.
- **Quando é levantado:** Levantado quando `CpfGenerator.new`, `#generate` ou `cpf_gen` recebe ao mesmo tempo um argumento `options` (instância ou `Hash`) e qualquer argumento nomeado não-`nil`.
- **Exemplo:**

```ruby
begin
  CpfGen::CpfGenerator.new({ format: true }, prefix: '123')
rescue CpfGen::InvalidArgumentCombinationError => e
  puts e.message
  # Pass either an options instance/Hash to `options`, or keyword arguments (format:, prefix:), not both.
end
```

- **Como resgatar:**

```ruby
rescue CpfGen::InvalidArgumentCombinationError
  # combinação inválida de argumentos desta biblioteca

rescue ArgumentError
  # erros nativos de argumento, incluindo InvalidArgumentCombinationError desta biblioteca
```

#### `CpfGen::ValidationError`

- **Herança:** `CpfGen::ValidationError < CpfGen::DomainError < RangeError` (inclui `CpfGen::Error`)
- **Categoria:** Erro de domínio — um valor falha uma regra de domínio que não é numérica nem de tamanho.
- **Quando é levantado:** Levantado quando `prefix` é inelegível (base zerada `"000000000"`, ou 9 dígitos repetidos como `"999999999"`).
- **Exemplo:**

```ruby
CpfGen.cpf_gen(prefix: '000000000') # levanta CpfGen::ValidationError
CpfGen.cpf_gen(prefix: '999999999') # levanta CpfGen::ValidationError
```

- **Como resgatar:**

```ruby
rescue CpfGen::ValidationError
  # esta falha exata de validação de domínio

rescue CpfGen::DomainError
  # falhas de domínio com raiz em RangeError desta biblioteca
```

#### Granularidade de rescue

```ruby
# 1) Classe nativa — captura uso incorreto de tipo desta biblioteca (e outros TypeErrors).
rescue TypeError
  # CpfGen::TypeMismatchError e qualquer outro TypeError (da biblioteca ou não)

# 2) CpfGen::DomainError — captura violações de regra de negócio sob DomainError.
rescue CpfGen::DomainError
  # CpfGen::ValidationError e outras subclasses de DomainError

# 3) CpfGen::Error — captura tudo o que a biblioteca levanta.
rescue CpfGen::Error
  # todo erro customizado que inclui CpfGen::Error

# 4) Classe folha específica — captura apenas aquele modo de falha.
rescue CpfGen::ValidationError
  # apenas CpfGen::ValidationError
```

Atributos relevantes:

- `TypeMismatchError`: `option_name`, `actual_input`, `actual_type`, `expected_type`
- `ValidationError`: `option_name`, `actual_input`, `reason` (falhas de prefixo); `expected_values` é sempre `nil` para CPF

Os setters de propriedade nunca aceitam `nil` diretamente — passe a constante `DEFAULT_*` correspondente para redefinir:

```ruby
options = CpfGen::CpfGeneratorOptions.new
begin
  options.prefix = nil
rescue CpfGen::TypeMismatchError => e
  puts e.message
  # CPF generator option "prefix" must be of type string. Got nil.
end

options.prefix = CpfGen::CpfGeneratorOptions::DEFAULT_PREFIX # redefinição explícita
```

Falhas de cálculo de dígitos verificadores pelo `cpf-dv` são tratadas internamente com nova tentativa de geração usando as mesmas opções resolvidas; em operação normal não são propagadas ao chamador.

### Outros recursos disponíveis

- **`CpfGen::CpfGeneratorOptions::CPF_LENGTH`**: `11`.
- **`CpfGen::CpfGeneratorOptions::CPF_PREFIX_MAX_LENGTH`**: `9`.
- **`CpfGen::CpfGeneratorOptions::DEFAULT_FORMAT`**, **`DEFAULT_PREFIX`**: Constantes de padrão no nível da classe.

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
