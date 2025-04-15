# Change Log

## Pre-release

## 8.3.0 (2025-04-15)

### Features

- padding character for inline code [#389](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/389)
  [b292624](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b292624f228596010145f63697a49cdd9b8d8ce7)
- check `disable_pattern` exists and notify if not [#386](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/386)
  [#388](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/388)
  [c283dec](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c283dec1ea94947499c36bb17443e15d6acf5cda)
- wrap `nvim_buf_set_extmark` in pcall use notify_once if it errors [#382](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/382)
  [1e2e9a3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1e2e9a386fbe41b869d3d0e000e19db72284585b)
- ignore option, checked before attaching [05e6a6d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/05e6a6d119f90b99829ecb7eb85428a226c0c05f)
- on.initial option, called before adding marks for the first time [#396](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/396)
  [91d40c2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/91d40c2f37a4373ec29a47fcf3ce656408d302dc)
- ability to conceal text based on lua patterns [#397](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/397)
  [51da7d1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/51da7d186f3f3be0ea00944c827293bc1dc5af8a)
- better anti-conceal for multi-line decorations [8355c85](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8355c85e4a34c2071fb9c78295aedf877116648b)

## 8.2.0 (2025-03-31)

### Features

- enabled flag for link footnote [#362](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/362)
  [9721ffe](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9721ffe230ec90e49c49ee33b5ca44c3fc689214)
- blink.cmp source registration [b8d93e8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b8d93e83a02dadddc6a566b1f60dab87190c1296)
  [62d6681](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/62d6681332365cfddbe916c888752834d9f7ad0c)
- improved completions [9f4ef68](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9f4ef684da01016c270af2bc2b862eb6823aa7ab)
- filter command completions [#372](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/372)
- improved advice in checkhealth [5cec1bb](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5cec1bb5fb11079a88fd5b3abd9c94867aec5945)
- avoid inline text for checkboxes when possible [#378](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/378)
  [f9badfb](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f9badfb5907a16c8e0d5f3c157d63bcea2aa555e)
- `code.language_icon` option [#376](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/376)
  [8ee2701](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8ee2701a6c4cdaef7ea0b27c13c26971ae3c9761)
  [7bf951b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7bf951b8ad93d47b90be290be6fc60da5788ddaa)
- code border for different conceal settings [e724a49](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e724a49dee315744d6f5d3c651ddd604cc7afc52)
- use builtin extends query in vim.treesitter.query.set for injections [c91fa46](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c91fa46fc8d79f5577beac70a459f30ec17a60c2)
- completion filter for callouts and checkboxes [#380](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/380)
  [84d413b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/84d413b0c432adaeaf3dcaac646638bd99d06aa6)
- separate code border highlight, allow false value [a1fc4e5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a1fc4e559252baa128c471adadf0be045abd542d)
- ability to enable and disable atx and setext heading rendering [#381](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/381)
  [a020c88](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a020c88e9552b50916a78dec9eeb4656c6391e6d)
- reduce height of LSP hover doc window based on concealed lines [#384](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/384)
  [17b839b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/17b839bba4c5c0c791fec0f7015c7d0e4eac30b8)

### Bug Fixes

- account for indent when right aligning code language [125258a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/125258ac5bccd21651505d78dbd6120906243749)
- support for code border for 0.11, disable conceal_lines highlights [#351](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/351)
  [#352](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/352)
  [e6c8081](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e6c8081691881fd63b4d72cb472094ac190ac56e)

### Collaborator Shoutouts

- @water-sucks
- @williambdean

## 8.1.1 (2025-03-09)

### Bug Fixes

- padding for inline code and list items [#364](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/364)
  [932432c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/932432c7f569eb10115e14b93ec75e8ec6c526a3)

## 8.1.0 (2025-03-07)

### Features

- in-process lsp for engine agnostic completions [b56fa1b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b56fa1bc7b513f16a1c361b81438f4944b420a32)
- customize heading properties based on text [#320](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/320)
  [5c2440d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5c2440d932a4ba96840e5ce5a7bd40f0624bdaa2)
- allow html tags to be replaced with icons [#336](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/336)
  [6d446de](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6d446de33937633bc2104f45c943f4fae632b822)
- `autocommand` events and wiki link `body` customization [#228](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/228)
  [#345](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/345) [0df6719](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0df6719abc3b547bc5b7111a750d8d7e035a7234)
  [#350](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/350) [a53ac54](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a53ac54cebaad8dff37015d9b4c2d3b8c7d122ae)
- indent mode icon support [#343](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/343)
  [21623a9](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/21623a9ded5a5f3d1fbd8626a69c174fbeb0543e)
  [33673e6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/33673e630187669d52ec4f813b84d1d808e4619d)
- bullet `left_pad` & `right_pad` support functions [#349](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/349)
  [98a3b7d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/98a3b7d3a5befe495f0ab6ca967068f5f1da4421)
- bullet `scope_highlight` & `highlight` function support [#354](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/354)
  [9e3393b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9e3393b2a05fb2347cdc57ee399b910934fa9f83)
- use default `render_modes = true` (all) for LSP docs [#326](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/326)
  [17a7746](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/17a77463f945c4b9e4f371c752efd90e3e1bf604)
- update troubleshooting doc [f6c9e18](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f6c9e1841cf644a258eb037dae587e3cf407d696)
- update `lazy` preset to match `LazyVim` [4a28c13](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4a28c135bc3548e398ba38178fec3f705cb26fe6)
- latex position below [#347](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/347)
  [43a971e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/43a971e7da82e5622797b36450424ebd66cc9046)
- improve checkhealth [1ef7664](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1ef766414d754007b265881fa43d1984b5901742)
- after clear callback [#356](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/356)
- process conceal_lines metadata for `0.11` [595ac4f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/595ac4f7e7c0eaba7bf1d8fd6ec0f6ac91c7e33b)

### Bug Fixes

- update checkhealth to not rely on `nvim-treesitter` [#322](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/322)
  [e05a9f2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e05a9f22f31c088ece3fa5928daf546a015b66ee)
- lsp hover doc for `0.11` [#333](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/333)
  [b57d51d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b57d51d760f5e4f520414dbeb6dee3ec1ae07a83)

### Collaborator Shoutouts

- @dsully
- @mcDevnagh
- @filippo-biondi
- @Saecki (for in-process lsp inspiration)

## 8.0.0 (2025-02-06)

### ⚠ BREAKING CHANGES

This release includes only a single change which breaks any function values in user
configurations. Rather than passing a list of arguments to the functions we now
provide a single context table with the same information [591e256](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/591e2561a7236501a7e9ae88ebd9362d07a8c4a3).

The fix to any errors is straightforward as the fields of the context continue to
have the same names. So if you have an existing function like:

```lua
function(param1, param2)
    vim.print(param1)
    vim.print(param2)
end
```

The fixed version would be:

```lua
function(ctx)
    vim.print(ctx.param1)
    vim.print(ctx.param2)
end
```

If you use the same parameters many times in the function and don't want to add the
`ctx.` prefix everywhere you can add a line at the top to define local variables
with the same name as before and keep the rest of the function body unchanged:

```lua
function(ctx)
    local param1, param2 = ctx.param1, ctx.param2
    vim.print(param1)
    vim.print(param2)
end
```

The fields impacted are:

- The `parse` functions in `custom_handlers`:
  - `buf` -> `ctx.buf`
  - `root` -> `ctx.root`
- The callbacks in `on`: `on.attach` & `on.render`:
  - `buf` -> `ctx.buf`
- `bullet.icons` & `bullet.ordered_icons` if a non-default function was set:
  - `level` -> `ctx.level`
  - `index` -> `ctx.index`
  - `value` -> `ctx.value`
- `heading.icons` if a function was set:
  - `sections` -> `ctx.sections`

## 7.9.0 (2025-02-02)

### Features

- improve wiki link rendering [#284](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/284)
  [7b1b15f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7b1b15fc8891a62aeb3a0f75d0f7b1ec7fb98090)
- heading icons function value [#286](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/286)
  [bab0663](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/bab0663ecdb06b0ff846969764d6c67719ab0fcb)
  [cfe5746](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cfe57468a4ab44b745eddfbe90b63b9777ba7223)
- override based on `buflisted` [#285](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/285)
  [873bdee](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/873bdee806e381864a55f692bcbfe23269c8dc9d)
- completions provide space after marker [#292](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/292)
  [d7b646f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d7b646f2e6136d963e1bd3abbb9e2ac3fa90837a)
- more default link icons [#307](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/307)
  [8004461](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/800446143a2f06612da76c59d7e1daee82963d50)
- buffer level commands for enable, disable, & toggle [#313](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/313)
  [d15a144](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d15a144fe1966b5c4e5b35cf86e1039d4fdc5749)

### Bug Fixes

- ensure space for table cell padding [#287](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/287)
  [786d643](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/786d643ac7a691515d401930b8850f596992725d)
- bullet padding + heading borders [#297](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/297)
  [f0eb589](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f0eb5893556200e9f945c0f0ea3c83bbd20dd963)
- wrap nvim-cmp `register_source` in pcall [#298](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/298)
  [be3e3ab](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/be3e3ab807059ddd247a802e8253b0cd3edef5a3)
- check highlighter status when computing concealed regions [#300](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/300)
  [ad05586](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ad055861d17afe058bd835e82292e14a64b51b1d)
- difference in `nvim-cmp` and `blink.cmp` cursor [#310](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/310)
  [c85d682](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c85d682dce1ef3453868b91672bb2e65d0d95c68)
- many fixes to handle lazy loading from different plugin managers, and fixes for
  those fixes [#309](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/309)
  [1ba6fb7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1ba6fb7998985736ca3480366c9792be05b93ad7)
  [#315](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/315)
  [b9c98ff](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b9c98ff7d47dfe2a972f1b08340850c92e6ca9bc)
  [#317](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/317)
  [4645c18](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4645c1856933ac325911e468ab14de1c02e979b2)

## 7.8.0 (2025-01-04)

### Features

- individual components can all specify render modes [#269](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/269)
  [4d8e991](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4d8e991d0c6e5298b79a6fb5ee44a7925e88180d)
- nvim-cmp completion source [3d2dc15](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3d2dc15542e56671dd14dfbfff63434ec21d8fcd)
- blink.cmp completion source [3d2dc15](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3d2dc15542e56671dd14dfbfff63434ec21d8fcd)
- coq_nvim completion source [#258](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/258)
  [#259](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/259) [75cdf9d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/75cdf9d2b049f0e27440bd78cc52b39acd15cd6e)
- dash width and margin percent [#272](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/272)
- include icon provider warning in health check [032c640](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/032c6401b6f076adeb704bb8a3ac174fb813fbdb)
- inline code padding [#274](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/274)
  [65b263d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/65b263d6fc578131747f681d22f0b3a757e75443)
- handle more list types for completions [c00cc1e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c00cc1e2cbd5a55ca0c6c2e27fcf4a02ff731434)
- include markers in completion items based on context [#277](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/277)

### Bug Fixes

- nil check for window [#257](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/257)
  [eb8fdac](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/eb8fdace39e6eab96037539aace272f14e40fd80)
- check buffer is valid when getting name [#260](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/260)
  [0022a57](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0022a579ac7355966be5ade77699b88c76b6a549)

### Collaborator Shoutouts

- @argizuno
- @TheLeoP
- @Kurama622
- @AlexandreDoucet

## 7.7.0 (2024-12-07)

### Features

- footnote text superscript rendering [#241](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/241)
  [634acd5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/634acd5da964c32f6947cd0c7802d7a116662665)
  [1b5d117](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1b5d11734122d9451d2e5e2e567fd61a62822293)
- code border none [#246](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/246)
  [f3cda24](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f3cda24c71261f6a52f5ddafb95786684d862d87)
- expand default custom links [#245](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/245)
  [61850bf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/61850bf7df4af8398e97559a35b62378ba8435b1)
- bare URLs in angle brackets [#244](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/244)
  [401a6c9](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/401a6c9c4cf39e22b8487503dd7dfe37fc7fb064)
  [b6b903c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b6b903cc09df1441602fc04665fb12cef576a914)
- conceal html comments [#244](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/244)
  [558310a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/558310ae07b7bf0dffc478160513bb5c845f263c)
  [7674543](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7674543331701d05dc9f878e1fe62d1107dc2f5e)
- after render callback [#248](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/248)
  [c89e5e0](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c89e5e0719d07e1e2c0d3942b564ac916b6ffe9c)
- ordered list auto indexing [#250](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/250)
  [a7097f3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a7097f372ba8f8866cda5e98d5bc828f2856c96c)
  [#254](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/254)
  [4ac2804](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4ac28048b492d351b70ded7b58d3f1a816e6c0a2)

### Bug Fixes

- highlight index width calculation [#212](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/212)
  [3a319cd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3a319cdbefebf0079a7012dab6b1bfc18ca5b97f)

### Awesome Things

- fzf-lua integration [#1546](https://github.com/ibhagwan/fzf-lua/discussions/1546)
  [da70762](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/da707623447752ca8eb00b7606b8ffe7dac18ce0)

## 7.6.0 (2024-11-25)

### Features

- disabling background for code now keeps border [#220](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/220)
  [bee16b2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/bee16b21bf47b64ceda8c9bb281d4b576d329c0f)
- table support for all conceal levels [3da1bfc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3da1bfc4bd3a13fee57551f0b705ebcf2614d7a2)
- roll own type validation to remove vim.validate [d69a885](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d69a885e1bf21cb329d2eafe56fd80b6de627216)
- code block language icon from extension [#233](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/233)
  [78a2eb7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/78a2eb7fc273f36790aa390262f390a3265eedff)
- log_level off [#235](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/235)
  [48a52dd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/48a52dd5c847c59eac6ae5b96ff0123acd1a394d)
- highlighting in double equals [d6a82d7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d6a82d70765aa238b7ea48d257a1d57a92501423)
- heading border per level [#240](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/240)
  [c83fc56](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c83fc5694cd19c576af188f5f3313513bf467272)
- heading position right [#238](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/238)
  [e1879e0](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e1879e0ea3d5cee295b48335fc90e76ae8a63081)

### Bug Fixes

- padding & margin for code blocks indented with tabs [#230](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/230)
  [d80acb3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d80acb3f4ccc88052f65fa0a26e46c106b328bbe)
- check table rows after parsing [7f0143e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7f0143e9adf7140c8e3fa33a5bdf193d7a8f0429)
- conceal level 2 entities in tables [430a671](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/430a671655ac84a63f41cd3e940caebdd0a99434)
- ignore anti conceal for inline heading icons [017f370](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/017f370369f205b02331838b56c4a68eef0b317d)

## 7.5.0 (2024-11-04)

### Features

- custom checkbox scope_highlight [#207](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/207)
  [2f36ac1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2f36ac16df20e0c6512f14e2793f7b2ba235989c)
- handle and log latex converter errors [34044cd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/34044cdfcc90b87f32eb962f1fcd9119fc1a62a5)
- bullet icons list of lists [#217](https://github.com/MeanderingProgrammer/render-markdown.nvim/discussions/217)
  [04e75a3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/04e75a35900d9e6bc53eb0f18e2aeee140d6c5ae)
- icons for ordered lists [14673b0](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/14673b03963ef9bb9365474133306266fd4864f6)

### Bug Fixes

- skip updates when state is disabled [#208](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/208)
  [bea6f20](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/bea6f2078e34abdf5c2632f593651bb13205477f)
- disable rendering when left column is > 0 [1871dc4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1871dc4ced6fd775591a63df8e4c343ebaf1a2d2)
- skip updates when buffer in window changes [#209](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/209)
  [c6b59a2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c6b59a263cffbd6bf463fff03b28a35ad9f1a8e6)
- use first window if buffer is not current window [#210](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/210)
  [5137b5e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5137b5e198ddff8a26f88df7000ff8ca336e6fcd)

## 7.4.0 (2024-10-16)

### Features

- margin for paragraphs [#200](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/200)
  [d20d19f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d20d19fa54965f6eb94558c0b84fe9a942169fb4)
- `on.attach` buffer callback [8b4149b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8b4149b122cfbf58b79a552ae89b3df2ddc39786)
- allow empty lists for all heading properties [0c6de74](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0c6de743a8d3c61b87bc7db9ab97dcda12ca6818)
- wiki link config & language highlight [#205](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/205)
  [965c222](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/965c222076b2d289ed498730845d533780f3c7c7)
- code language name [#205](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/205)
  [18c7ef7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/18c7ef71fb4b8d83cb0160adc9127fc4d65ca42e)
- anti conceal per component per mode [#204](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/204)
  [fb6b3d1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/fb6b3d145e5e12b838c0b84124354802f381b1af)
  [29863dc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/29863dc5262954ea04d76bd564f2f63330b42d7f)
- align table cells according to indicators [c0082b7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c0082b7d9e33408ba4e451741d8aca2b1f5ed823)

### Bug Fixes

- bullet point right padding priority [#199](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/199)
  [b02c8ef](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b02c8ef72b10537a346556696b6e7fb354c8771f)
- window offset bottom calculation [e13ac2c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e13ac2c05d2f081453db1451ec07fbd8be33ceec)

## 7.3.0 (2024-10-04)

### Features

- checkbox scope highlight [cb90caf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cb90caf64951b5b7515def7783b32e73883e374c)
- plus / minus metadata dash rendering [35c37ca](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/35c37ca9f7955f9fa57eaee1c16edb3c80c40462)
- callouts override quote icon [#194](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/194)
  [1eb3b74](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1eb3b74873d2dbb9d5a3635bf4a14e77e897d29f)

### Bug Fixes

- only set option value if it changes [#186](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/186)
  [91ce0b5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/91ce0b5a6314b091bcba1541f557f591c7ddfe06)
- handle offset conceal nodes [0cab868](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0cab868ce2b017ff9deccee87c289dc1915317be)
- indented table border [#191](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/191)
  [efb4c48](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/efb4c48c3b4de7cc3d01ec54d794a2509ae0c1c8)
- heading border at start & end virtual text [#187](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/187)
  [e91b042](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e91b042b3865d2d040a0e21e0a3b13fb57f24094)

## 7.2.0 (2024-09-26)

### Features

- `pipe_table.cell` value `trimmed` [#175](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/175)
  [c686970](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c68697085441d03a20eee15d4d78e2e5a771569a)
- configurable padding highlight [#176](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/176)
  [095078d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/095078d931ce23b544face8ca7b845adf7fad7e9)
- pad setext header lines [75a0a95](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/75a0a9596a91130fae43d3b7c0d6c651645ef1df)
- center headings and code blocks [#179](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/179)
  [0986638](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0986638b381a4b01eb108bb946f3a67a9eb3d0ec)
  [67288fe](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/67288febca78b7aac8fae9543ef8980237e27d2a)
- integrate with lazy.nvim filetypes [cb9a5e2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cb9a5e2412d21c7a89627e0d6da5459acbc0eb9c)
- bullet left & right padding on all lines of items [#181](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/181)
  [3adb9d5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3adb9d539a016bc63fee83aa740e38fa4eeab094)
- heading margin / padding based on level [#182](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/182)
  & border virtual option [#183](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/183)
  [aad1a12](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/aad1a1220dc9da5757e3af3befbc7fc3869dd334)
- config command to debug configurations [a9643f4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a9643f4377f39f4abf943fbc73be69f33f5f2f1d)
- same buffer in multiple windows [#184](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/184)
  [767707e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/767707e928389996e8860f03552cf962afb0bfb2)

### Bug Fixes

- window options on alternate buffer switch [#177](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/177)
  [f187721](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f187721a5381f4443ef97ad1a7c0681a65511d28)
- update when window scrolled [#185](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/185)

### Collaborator Shoutouts

- @Bekaboo

## 7.1.0 (2024-09-19)

### Features

- logging improvements [2b86631](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2b86631c153e24682a1a2d05e37a0f4f94e9b827)
  [2424693](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2424693c7a4c79641a7ea1e2a838dbc9238d6066)
- table min width [f84eeae](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f84eeaebac278e26bd2906fd47747631716a5edb)
- new debug API for development [6f87257](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6f8725746ecadae0ae5ab3e7a1a445dad6b2e231)
- `render_modes` as a boolean [7493db6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7493db6d3fe3f6679549e6020498f72e97cd9b73)
- anti conceal selected range in visual mode [#168](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/168)
  [5ff191f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5ff191f0c7457ede2fd30ecf76ab16c65118b4ee)
  [354baf4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/354baf485370b670bb1c1cd64309438607b0465d)
- disable rendering in diff mode [#169](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/169)
  [01b38dc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/01b38dcf7d0a99620547651fb59a3ba521ba12d5)
- reload runtime highlights on color scheme change [199cc52](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/199cc52ae970c86a6df843bd634db4dd932be1f0)

### Bug Fixes

- indent with block widths [044f2d6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/044f2d6d76712de69a79b25a7cd8311cb505a9f4)
- nil buffer state [#171](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/171)
  [#172](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/172)

### Collaborator Shoutouts

- @xudyang1

## 7.0.0 (2024-09-13)

### ⚠ BREAKING CHANGES

- `indent.skip` -> `indent.skip_level` [a028fbe](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a028fbe8f40b329ced721efba15a59ea31db8651)
  - Renamed within hours of adding

### Features

- add missing obsidian aliases [74b77c7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/74b77c794d64d9d5a27c2a38ac254d9654fcad1f)
- store components in context, avoids duplicate queries [d228a3c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d228a3cb40f9e9687c3142cca1f46c4d3e985f7a)
- improve health check for obsidian.nvim conflict [4d2aea3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4d2aea341a5d0bf2a01adc0ad4ecf5d4877e1bd0)
  - anyone using `acknowledge_conflicts` in their config should remove it
- performance getting callouts and checkboxes [5513e28](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5513e283973627385aec9758b00fc018e3a8303f)
- indent based on heading level rather than nesting [27cc6ce](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/27cc6ce2605a2d42900b02648673a1de9b8cb933)
- configurable starting indent level [cdb58fc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cdb58fc97c49a1ab75b35d99183c35b5863e845a)
- configurable heading indents so body is offset [#161](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/161)
  [a028fbe](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a028fbe8f40b329ced721efba15a59ea31db8651)

### Bug Fixes

- only create foreground when inversing highlight [#154](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/154)
  [12fdb6f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/12fdb6f6623cb7e20da75be68858f12e1e578ffd)
- leading spaces in checkbox bullet [#158](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/158)
  [06337f6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/06337f64367ef1f1115f0a9ba41e49b84a04b1a4)
- heading borders with indentation [#164](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/164)
- indenting heading borders with single empty line between [2ddb145](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2ddb145c9e60267a723083b5966189b13febc72b)

### Collaborator Shoutouts

- @lukas-reineke

## 6.3.0 (2024-08-29)

### Features

- integrate treesitter injections [#141](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/141)
  [5ff9a59](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5ff9a598622422100280769147ad5feff411c6da)
- email link icon [74502e5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/74502e5d34efa68dde051bcc6bf28db9748922c7)
- deterministic custom link order [#146](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/146)
  [42dbd09](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/42dbd097d73d8c833f886f35ca3be2065973c628)
- setext headings [27d72d7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/27d72d75035c0430d671f8295ca53c71c4a04633)

### Bug Fixes

- tables indented and no spaces in cells [#142](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/142)
  [a3617d6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a3617d61fcf4cec623ee6acb48570589d7ddcb03)
- skip tables with errors [c5f25ef](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c5f25ef19ed9bb3da4e7d947c5119cf8a6191beb)
- render table border below delimiter when no rows [631e03e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/631e03e2cfc153c38327c9cc995f4e7c2bbd9b24)
- nil check current line [92e1963](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/92e1963d1ff789bfd4e62867fbcb06fe3c67124e)

## 6.2.0 (2024-08-21)

### Features

- handle imperfectly spaced tables using max width [166a254](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/166a254aaf5b4333fe015a29a66ad99c276538ea)
- anti-conceal margin [abc02f3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/abc02f35cd6cb28e9b8eb37c88fc863a546367bf)
- log error when mark is skipped [#132](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/132)
  [7986be4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7986be47531d652e950776536987e01dd5b55b94)
- checkbox: position [#140](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/140)
  [275f289](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/275f28943ab9ce6017f90bab56c5b5b3c651c269)
- code: independent language padding [#131](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/131)
  [739d845](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/739d8458d6c5742fbcf96a5961b88670fefa1d53)
- full filetype overrides [952b1c0](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/952b1c077a5967f91228f57a6a4979f86386f3c4)
- basic org-indent-mode behavior [#134](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/134)
  [277ae65](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/277ae65ab14c23525ce3dbc9b812244c1976049e)

### Bug Fixes

- wiki links nested in tables [72688ba](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/72688baea4ef0ed605033bf654b54d801b6a5f01)
- code block background when indented in lists [#133](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/133)
  [4c823b1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4c823b1df151dbf1ed3ddaacac517be606b1e145)
  [d1cec33](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d1cec33f0d59bac5c2854312d2ea0483b44dfd11)
- do not set noref in vim.deepcopy [#139](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/139)
- gate virt_text_repeat_linebreak to neovim >= 0.10.0 [98f9965](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/98f996563591b753470942165d2d5134df868529)
- account for folds when computing visible range [#138](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/138)
  [cd0a5ad](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cd0a5ad8c77c3754d02437048bc0bb604a2fe268)

### Collaborator Shoutouts

- @P1roks
- @Biggybi

## 6.1.0 (2024-08-11)

### Features

- created wiki with examples [here](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki)
- code block: min_width [4b80b4f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4b80b4fb8f81dc39da23a13a0b4e971731c5f849)
- list bullet: left_pad [e455c4f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e455c4f4886d250bd610165a24524da2c6adce80)
- preset: obsidian & lazy [96988cc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/96988cc76414a2f69a57c5dbaca7bf9336c9cb52)
- pipe table: preset round [c4eb6bf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c4eb6bf30525fdc7efaf5f33bcb0fa9491ace245)
  - double & heavy [3bacd99](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3bacd9903e3b4f81b918380a0f170be6713a4da1)
- heading: left_pad, right_pad, & min_width [#121](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/121)
  [6392a5d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6392a5dfa10f367e10fe58ea9c2faf3179b145d5)
- heading: border [#123](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/123)
  [b700269](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b7002694a7a794f8d8a6a0cc54769628cf1cf9d8)
- heading: width based on level [#126](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/126)
  [f06d19a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f06d19ad58e4977f02f7885ea00c3ecfdfe609ff)

### Bug Fixes

- same buffer in multiple windows [#122](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/122)
  [1c7b5ee](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1c7b5ee30d8cf6e52628862dbd06f2e23ecb888e)
- link icon in headings [#124](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/124)
  [f365cef](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f365cef5c1d05fd2dd390e1830d5c41f2d1f2121)
- provide patch for previous [LuaRock](https://luarocks.org/modules/MeanderingProgrammer/markdown.nvim)
  [v5.0.1](https://github.com/MeanderingProgrammer/render-markdown.nvim/releases/tag/v5.0.1)

## 6.0.0 (2024-08-05)

### ⚠ BREAKING CHANGES

- `custom_handlers` render method deleted and replaced with parse method. The
  former assumed rendering inside, the latter gets marks back so they are not
  interchangeable. Notice of deprecation has been available for a month since
  [726c85c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/726c85cb9cc6d7d9c85af6ab093e1ee53b5e3c82).
  - Ultimately removed in [83b3865](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/83b386531a0fa67eab1e875f164aff89f560c11b)
  - In order to fix:
    - Implement `parse` method instead of `render`, no direct translation
- Remove `profile` field in favor of benches [dcfa033](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/dcfa033cb39bc4f30019925aa91d3af5ec049614)
  - In order to fix:
    - `profile` field was only meant for development, should not have any users
- Updated buftype options
  - In order to fix:
    - `exclude.buftypes.<v>` -> `overrides.buftype.<v>.enabled = false`
    - `sign.exclude.buftypes.<v>` -> `overrides.buftype.<v>.sign.enabled = false`

### Features

- Performance only parse & render visible range [c7a2055](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c7a20552b83c2abad92ac5e52feb7fe3b929f0a7)
- Support full buftype options [9a8a2e5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9a8a2e5bd204931646f1559235c7c4a7680ecbcd)
- Inline heading position [#107](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/107)
  [345596b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/345596bb6ef2b0c0a145c59906c2e84dbddfbbd4)
- Pre-compute concealed data once per parse cycle [fcd908b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/fcd908bafb96e4a30abe7bf8f502790b93ea85ac)
  [3bdae40](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3bdae400e079a834ae12b658bf1115abf206bb4c)
- Improve table parsing performance by storing state [4d046cd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4d046cdf65393a62c0eb209e01574b39f28bc01b)
- Improve performance of showing / hiding marks by storing mark id [ef0c921](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ef0c921858cbe079d40304200af60b6ce0c99429)
- Hide code block background based on language [#110](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/110)
  [9725df2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9725df2306409a836a142244c9eabde96268d730)
- Right aligned code block language hint [#73](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/73)
  [4d8b603](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4d8b6032b659a45582089de8bcd839f8ccc4161d)
- Obsidian like custom callout titles [#109](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/109)
  [a1bcbf4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a1bcbf4858d1834f922029b5fc6ae55a7417bd51)
- Support for wikilinks [e6695b4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e6695b4ff330cf9c216fe5e40491cee39d93383a)
- Skip parsing when no text changes and already parsed [#115](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/115)
  [6bb1d43](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6bb1d43c9e360929d4497a0459084b062bfe9de5)
- Callouts on wrapped lines kind of [#114](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/114)
  [66110dd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/66110ddfc27b8785f3046dcf516a4f75d6a8f0f9)
- Custom link icons based on destination [#117](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/117)
  [d5b57b3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d5b57b32397c0be1f511f4cdf2b876c5b1f01144)

### Bug Fixes

- Repo has been renamed `markdown.nvim` -> `render-markdown.nvim`, one can argue
  this was a long standing bug. Everything internally & externally already used the
  `render markdown` naming convention except for the repo itself. Since Github
  treats the URLs the same and redirects between the 2 there should be no breaking
  changes from this. [aeb5cec](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/aeb5cec617c3bd5738ab82ba2c3f9ccdc27656c2)
  [090ea1e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/090ea1e9913457fa8848c7afdbfa3b73bb7c7ac8)
- Block code rendering with transparent background [#102](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/102)
- Remove broken reference to `profiler` module [#105](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/105)
  [15d8e02](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/15d8e02663aa58f215ecadbcebbd34149b06a7bc)
- Loading user configuration with vim-plug [#111](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/111)
  [4539c1a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4539c1a5d5f961c11bfee7622aa127f4b8a1de16)

### Collaborator Shoutouts

- @scottmckendry

### Awesome Things

- Supported by catppuccin colorscheme [#740](https://github.com/catppuccin/nvim/pull/740)

## 5.0.0 (2024-07-27)

### ⚠ BREAKING CHANGES

- Add additional user command controls to allow lazy loading on command [#72](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/72)
  [3c36a25](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3c36a257e2a5684b274c1a44fddd64183c7a7507)
- In order to fix:
  - `RenderMarkdownToggle` -> `RenderMarkdown toggle`

### Features

- Full anti-conceal support [726c85c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/726c85cb9cc6d7d9c85af6ab093e1ee53b5e3c82)
- Link custom highlight groups to better support color schemes [#70](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/70)
  [0f32655](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0f3265556abf4076170ac0b6a456c67d814ece94)
  [6aa19e9](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6aa19e9bf36938049e36cd97aafedfe938de8d79)
- Code blocks support block / fixed width [#88](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/88)
- Separate highlight group for inline code blocks [#87](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/87)
- Disable heading icons by setting an empty list [#86](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/86)
- Support full_reference_link nodes [#75](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/75)
  [5879827](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5879827bc36830dc5516d09e7df1f365ca615047)
- Disable signs per component [#64](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/64)
  [9b771cc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9b771cc485677f1aa5873642e33a3522b270225d)
- Improve health check, plugin conflicts, treesitter highlights [#89](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/89)
  [a8a3577](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a8a35779437e63d930cf69312fe80c3993c80b5b)
  [8d14528](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8d1452860e1c6b03d814af10024c7edc88e44963)
- Left padding for code blocks [0bbc03c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0bbc03c5a208274c89f15c625a0ee3700c9adda8)
- Right padding for list bullets [#93](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/93)
  [2c8be07](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2c8be07c7760dc7e05b78f88b6ddf8a9f50e410b)
- Fixed width dash [#92](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/92)
  [ff1b449](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ff1b449bd02ab1a72a4ac9e621c033e335c47863)
- Case insensitive callout matching [#74](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/74)
  [123048b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/123048b428eb85618780fcef9ea9f4d68b5d2508)
- Improve lazy.nvim instructions [#80](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/80)
- Improve latex compatibility [#90](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/90)
  [695501b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/695501bd98b1f2ec052889fc4faef24dedd7091b)
- Heading block width [#94](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/94)
  [426b135](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/426b13574c8264636e5660e5f5a3b4f5e3d5a937)
- Alignment indicator for pipe tables [#91](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/91)
  [a273033](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a27303384570b85ee4538fa5f30eb418fef01ec7)
- Auto-setup using plugin directory [#79](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/79)
  [67bdd9b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/67bdd9b68c6519bf1d5365f10c96107032bb4532)
- Upload to LuaRocks [#78](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/78)

### Bug Fixes

- Rendering for buffers with no cached marks [#65](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/65)
  [#66](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/66) [4ab8359](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4ab835985de62b46b6785ae160f5f709b77a0f92)
- Code highlight border with notermguicolors [#77](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/77)
  [#81](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/81)
- Hide cursor row in active buffer only [56d92af](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/56d92af432141346f2d414213726f7a45e82b2b3)
- Remove gifs from repo, fix concel on window change [51eec4e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/51eec4e4cab69faf7e37c183d23df6b9614952db)
- Wrap get_parser in pcall [#101](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/101)
  [ddb4547](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ddb454792dd85c0f6039ec14006aecaee67e782d)

### Collaborator Shoutouts

- @folke
- @scottmckendry
- @akthe-at
- @jeremija
- @chrisgrieser
- @Zeioth
- @joshuarayton
- @mrcjkb

### Awesome Things

- Added to LazyVim distribution [#4139](https://github.com/LazyVim/LazyVim/pull/4139)
- Supported by tokyonight.nvim colorscheme [71429c9](https://github.com/folke/tokyonight.nvim/commit/71429c97b7aeafecf333fa825a85eadb21426146)
- Supported by cyberdream.nvim colorscheme [ba25d43](https://github.com/scottmckendry/cyberdream.nvim/commit/ba25d43d68dd34d31bee88286fb6179df2763c31)
- Supported by rose-pine colorscheme [#303](https://github.com/rose-pine/neovim/pull/303)

## 4.1.0 (2024-07-14)

### Features

- Improve handling conealed text for tables, code blocks, and headings. Add 'padded'
  cell style which fills in concealled width. Inline headings when there is no space.
  [#49](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/49) [#50](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/50)
  [9b7fdea](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/9b7fdea8058d48285585c5d82df16f0c829b2384)
  [5ce3566](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5ce35662725b1024c6dddc8d0bc03befc5abc878)
- Add thin border style for code blocks [#62](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/62)
  [3114d70](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3114d708283002b50a55be0498668ef838b6c4cf)
- Add icons to images and links [#55](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/55)
  [501e5e0](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/501e5e01493204926aa4e2a12f97b7289636b136)
- Add signs for headings and code blocks [7acc1bf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7acc1bf0ecc207411ad6dcf8ecf02f76fe8cbe13)
- Allow signs to be disabled based on buftype, improve highlight color [#58](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/58)
  [#61](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/61) [d398f3e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d398f3e9f21d88e1de51594cd4a78f56a3a3eb9e)
- Add defaults for all Obsidian callouts [be3f6e3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/be3f6e3c6ce38399464a9c3e98309901c06ca80e)
- Add code style 'language', adds icon without background [#52](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/52)
  [308f9a8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/308f9a826e371e33512234e4604cf581fe1d4ef8)
  [e19ed93](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e19ed93d75216f8535ede4d401e56ef478856861)
- Allow table border to be configured [b2da013](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b2da01328e8c99fc290c296886f2653315b73618)
- Improved health check configurable buftype exclude [1d72b63](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/1d72b6356dbb48731b02bce0bc48774f08a47179)
- Use more common heading highlights [e099bd8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e099bd80ee286f491c9767cda7614233295aced0)
- Allow each component to be individually disabled [b84a788](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b84a788f51af7f0905e2351061b3429fa72254b6)

### Bug Fixes

- Account for leading spaces in code blocks [#60](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/60)
  [48083f8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/48083f81aa1100293b92755a081764f61dce2f1f)
- Use concealled text width for 'raw' table cell style [8c71558](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8c71558a1cf959c198bb0540a16ae09e93cead62)

## 4.0.0 (2024-07-08)

### ⚠ BREAKING CHANGES

- Group properties by component [a021d5b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a021d5b502dcccd28412102f01d0ecd8ef791bd4)
- If you want to punt dealing with these changes feel free to use the `v3.3.1` tag
- In order to fix:
  - `start_enabled` -> `enabled`
  - Latex
    - `latex_enabled` -> `latex.enabled`
    - `latex_converter` -> `latex.converter`
    - `highlights.latex` -> `latex.highlight`
  - Headings
    - `headings` -> `heading.icons`
    - `highlights.heading.backgrounds` -> `heading.backgrounds`
    - `highlights.heading.foregrounds` -> `heading.foregrounds`
  - Code
    - `code_style` -> `code.style`
    - `highlights.code` -> `code.highlight`
  - Dash
    - `dash` -> `dash.icon`
    - `highlights.dash` -> `dash.highlight`
  - Bullets
    - `bullets` -> `bullet.icons`
    - `highlights.bullet` -> `bullet.highlight`
  - Checkbox
    - `checkbox.unchecked` -> `checkbox.unchecked.icon`
    - `highlights.checkbox.unchecked` -> `checkbox.unchecked.highlight`
    - `checkbox.checked` -> `checkbox.checked.icon`
    - `highlights.checkbox.checked` -> `checkbox.checked.highlight`
  - Quote
    - `quote` -> `quote.icon`
    - `highlights.quote` -> `quote.highlight`
  - Table
    - `table_style` -> `pipe_table.style`
    - `cell_style` -> `pipe_table.cell`
    - `highlight.table.head` -> `pipe_table.head`
    - `highlight.table.row` -> `pipe_table.row`
  - Callouts
    - `callout.note` -> `callout.note.rendered`
    - `callout.tip` -> `callout.tip.rendered`
    - `callout.important` -> `callout.important.rendered`
    - `callout.warning` -> `callout.warning.rendered`
    - `callout.caution` -> `callout.caution.rendered`
    - `highlights.callout.note` -> `callout.note.highlight`
    - `highlights.callout.tip` -> `callout.tip.highlight`
    - `highlights.callout.important` -> `callout.important.highlight`
    - `highlights.callout.warning` -> `callout.warning.highlight`
    - `highlights.callout.caution` -> `callout.caution.highlight`
    - `callout.custom.*` -> `callout.*` (i.e. unnest from custom block)
  - Others
    - Any remaing changes are covered within that component.
    - I.e. `code_style` is covered in Code, `highlights.table` is covered in
      Table, `highlights.callout.note` is covered in Callouts, etc.

## 3.3.1 (2024-07-08)

### Features

- Improved health check [7b8110b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7b8110b675766810edcbe665f53479893b02f989)
- Use lua to document components [d2a132e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d2a132e8ad152a3ab7a92012b0b8bf31dcb6344b)

## 3.3.0 (2024-07-06)

### Features

- Improve performance by attaching events at buffer level [#45](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/45)
  [14b3a01](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/14b3a01fbd7de25b03dafad7398e4ce463a4d323)
- Reduce startup time by scheduling treesitter parsing [6d153d7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6d153d749b9297c0e5cb74716f2a8aacc8df3d0e)
- Support arbitrary nesting of block quotes & code blocks [770f7a1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/770f7a13515b9fd8d4ed4d6a1d8a854b3fbeeb7e)
- Prefer `mini.icons` for code blocks over `nvim-web-devicons` [353e445](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/353e4459938dd58873772e27a45c1d92bc83bafc)
- Support custom checkbox states [#42](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/42)
  [ff3e8e3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ff3e8e344004bd6acda48a59f6780b5326e8a453)
- Support custom callouts [8f5bbbd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/8f5bbbd9e29508e2fc15b6fa9228eada15fca08a)

### Bug Fixes

- Fix language selection logic for code blocks [#44](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/44)
  [90072fd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/90072fdbc28042add4cd08bef282df032bf6ac42)

## 3.2.0 (2024-06-28)

### Features

- Make default icons consistent [#37](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/37)
  [7cfe1cf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7cfe1cfa3b77f6be955f10f0310d5148edc69688)
- Document known limitations [#34](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/34)
  [#35](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/35)
  [0adb35c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0adb35cc190d682d689a1a8415d5980c92708403)
- Add troubleshooting guide [#38](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/38)
  [6208fc4](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6208fc408d444024f5977ea02b83dea8fe177cfa)
- Add note for `vimwiki` users [#39](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/39)
  [56ba207](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/56ba207c860fd86250dcfb9d974a2cf67a5792d7)
- Add issue templates [e353f1f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e353f1f566195176b54e2af5b321b517ac240102)
- Add `raw` cell style option [#40](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/40)
  [973a5ac](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/973a5ac8a0a7e8721576d144af8ba5f95c057689)
- Allow custom handlers to extend builtins [870426e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/870426ea7efe3c0494f3673db7b3b4cb26135ded)
- Add language icon above code blocks [6eef62c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6eef62ca1ef373943ff812d4bece94477c3402f2)
- Use full modes instead of truncated values, support pending operation [#43](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/43)
  [467ad24](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/467ad24c4d74c47f6ad346966a577f87f041f0e7)

### Bug Fixes

- Get mode at time of event instead of callback execution [#36](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/36)
  [b556210](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b556210e6c8759b7d23d5bc74c84aaafe2304da4)
- Update health check to work with neovim 0.9.5 [64969bc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/64969bc94a9d633dc23b59a382cab407c99fecb1)
- Handle block quotes with empty lines [#41](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/41)
  [6f64bf6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6f64bf645b817ff493a28925b1872a69d07fc094)

### Contributor Shoutouts

- @AThePeanut4

## 3.1.0 (2024-06-05)

### Features

- Add debug statements to `latex` handler, make converter configurable [7aedbde](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7aedbde39ab236d27096a8f8846235af050dbd7f)
- Split demo into separate files [ea465a6](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/ea465a6656e70beeeb6923e21a62f90643b4808f)
- Support highlighting callout quote marker based on callout [#24](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/24)
  [3c6a0e1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3c6a0e1914756809aa6ba6478cd60bda6a2c19ef)
- Add health check for `latex` requirements [#32](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/32)
  [a2788a8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a2788a8c711539d9425a96e413a26b67eba60131)

## 3.0.0 (2024-05-31)

### ⚠ BREAKING CHANGES

- Allow all window options to be configurable between rendered and non rendered view
  [#31](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/31)
  [258da4b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/258da4bcdecdc83318a515fc4c6c3e18c0c65a61)
- In order to fix:
  - `conceal = { default = <v1>, rendered = <v2> }` ->
    `win_options = { conceallevel = { default = <v1>, rendered = <v2> } }`

### Contributor Shoutouts

- @masa0x80

## 2.1.0 (2024-05-31)

### Features

- Support github markdown callout syntax [#20](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/20)
  [43bbefd](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/43bbefd410333a04baf62ddfa8bb2a2d30a1bbc1)
- Add health check on treesitter highlights being enabled [#28](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/28)
  [c1d9edc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c1d9edc2f2690ef326bd8afbe7fc080412cbb224)
- Script logic to update state config class and README from init.lua [d1cd854](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d1cd8548dbe139657275e31bcc54f246e86c5ce3)
- Validate user config in health check [6f33a30](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/6f33a30f73783bb10900cb2f9468f314cad482b4)
- Support user defined handlers [#30](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/30)
  [473e48d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/473e48dd0913d2e83610c86c5143a07fd7e60d4e)

### Bug Fixes

- Use strdisplaywidth in all string length calculations [#26](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/26)
  [7f90f52](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/7f90f522750111c32b0515814398514d58f66b23)

## 2.0.0 (2024-05-21)

### ⚠ BREAKING CHANGES

- Allow multiple kinds of table highlight behaviors [#21](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/21)
  [49f4597](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/49f45978fbb8fcf874f3b6967db4a6ea647df04b)
- In order to fix:
  - `fat_tables = true` -> `table_style = 'full'`
  - `fat_tables = false` -> `table_style = 'normal'`

## 1.2.0 (2024-05-21)

### Features

- Add simple logging [467c135](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/467c13523153f9b918c86037d0b5f2a37094cb88)
- Make start state configurable [#16](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/16)
  [#17](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/17)
- Add unit / kinda integ test [b6c4ac7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b6c4ac787b357493e75854354329a2442475fcc1)
- Add packer.nvim setup to README [#19](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/19)
  [9376997](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/93769977e0821a74bed797c2a589a4956200d497)
- Update for 0.10.0 (no user impact) [0581a9a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/0581a9add614cddbc442d6b483139e43e46c1f0e)
- Disable rendering on large files [e96f40d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e96f40d85be763427b00d8a541cf3389b110431f)
- Operate at event buffer level rather than current buffer [41b955c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/41b955c45db3602169c567546744fafdd43c27b9)

### Bug Fixes

- Fix bullet point rendering with checkbox [#18](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/18)
  [#22](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/22)
  [e38795f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e38795f3641ffb5702bf289f76df8a81f6163d32)
- Disable plugin on horizontal scroll [#23](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/23)
  [966472e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/966472e123195cb195e7af49d7db248ce104bee8)

### Contributor Shoutouts

- @cleong14
- @dvnatanael

## 1.1.0 (2024-04-13)

### Features

- Configurable file types [d7d793b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/d7d793baf716db965e6f4f4cc0d14a640300cc26)
- Add toggle command [#4](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/4)
  [fea6f3d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/fea6f3de62d864633ffe4e1e0fd92d1e746f77ed)
- Use buffer parser to handle injections [#3](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/3)
  [e64255d](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/e64255d52dcdf05eb37d9e93fbfd300648c4c4dd)
- Add latex support [#6](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/6)
  [138a796](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/138a7962fcbe9cddcb47cc40a58ec0f5ab99ddfe)
  [da85a5e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/da85a5e5885f1a11ab2b7a9059c16f3eede89bfe)
- Support block quotes [106946a](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/106946ae924706c885bda14a9160398e79880f30)
- Make icons bigger for certain font setups [#19](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/9)
  [38f7cbc](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/38f7cbcc0024737901ba87ee8bf1a6d466f99774)
- Support inline code [df59836](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/df5983612081397293c1e573c91de33639f2bbe6)
- Dynamic conceal level [#10](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/10)
  [c221998](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/c2219984fa1ddc5d3f6a76c1c1ad0744aa9f9011)
- Add Vimdoc [cdc58f5](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/cdc58f576582ab524192eca5611f05dbe2b6b609)
- Add fat tables option [fb00297](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/fb00297774c6f44c0cc3346459ed85168ac93dce)
- Support list icon based on level [#1](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/1)
  [#11](https://github.com/MeanderingProgrammer/render-markdown.nvim/pull/11)
- Refactor + latex cache [2b98d16](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/2b98d16f938dc9cedaa5f1c0659081035655f781)
- Support horizontal break [af819f3](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/af819f39c63aeb09ff3801dbfd5188cea55e48e7)
- Support checkboxes [90637a1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/90637a1120de47a3be57b00b7db4eee0d24834c8)

### Bug Fixes

- Leading spaces in list [#2](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/2)
  [#5](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/5)
  [df98da8](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/df98da81375e5dc613c3b1eaa915a847059d48d9)
- Passing custom query does not work [#7](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/7)
  [70f8f4f](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/70f8f4f64d529d60730d6462af180bbec6f7ef18)
- Ignore ordered lists for bullet points [#7](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/7)
  [f5917d2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/f5917d2113ce2b0ce8ce5b24cfbd7f45e0ec5e67)
- Dynamic heading padding [#12](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/12)
  [a0da7cf](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/a0da7cfe61dd1a60d9ca6a57a72ae34edb64dbc9)

### Contributor Shoutouts

- @lkhphuc
- @redimp
- @shabaev

## 1.0.0 (2024-03-21)

### ⚠ BREAKING CHANGES

- Changes folder from `markdown` to `render-markdown` to reduce chances of name
  collision in require statements [07685a1](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/07685a1838ad3f4e653a021cde5c7ff67224869f)
- In order to fix:
  - `require('markdown')` -> `require('render-markdown')`

## 0.0.1 (2024-03-21)

### Features

- Support rendering headings & code blocks [4fb7ea2](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4fb7ea2e380dd80085936e9072ab851d2174e1b0)
- Mode based rendering [3fd818c](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/3fd818ccfbb57a560d8518e92496142bc644cb80)
- Supprt rendering tables [fe2ebe7](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/fe2ebe78ffc3274e681bd3f2de6fec0ed233db52)
- Add basic health check [b6ea30e](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/b6ea30ef6b7ba6bfbe3c5ec55afe0769026ff386)
- Customize icon based on heading level [208599b](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/208599b0ca2c3daac681cf777ff3be248c67965b)
- Create auto demo script [03a7c00](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/03a7c0044b7e85903f3b0042d600568c37246120)
