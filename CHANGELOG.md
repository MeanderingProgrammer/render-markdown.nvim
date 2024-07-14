# Change Log

## 4.1.0 (2024-07-14)

### Features

- Improve handling conealed text for tables, code blocks, and headings. Add 'padded'
  cell style which fills in concealled width. Inline headings when there is no space.
  [#49](https://github.com/MeanderingProgrammer/markdown.nvim/issues/49) [#50](https://github.com/MeanderingProgrammer/markdown.nvim/issues/50)
  [9b7fdea](https://github.com/MeanderingProgrammer/markdown.nvim/commit/9b7fdea8058d48285585c5d82df16f0c829b2384)
  [5ce3566](https://github.com/MeanderingProgrammer/markdown.nvim/commit/5ce35662725b1024c6dddc8d0bc03befc5abc878)
- Add thin border style for code blocks [#62](https://github.com/MeanderingProgrammer/markdown.nvim/issues/62)
  [3114d70](https://github.com/MeanderingProgrammer/markdown.nvim/commit/3114d708283002b50a55be0498668ef838b6c4cf)
- Add icons to images and links [#55](https://github.com/MeanderingProgrammer/markdown.nvim/issues/55)
  [501e5e0](https://github.com/MeanderingProgrammer/markdown.nvim/commit/501e5e01493204926aa4e2a12f97b7289636b136)
- Add signs for headings and code blocks [7acc1bf](https://github.com/MeanderingProgrammer/markdown.nvim/commit/7acc1bf0ecc207411ad6dcf8ecf02f76fe8cbe13)
- Allow signs to be disabled based on buftype, improve highlight color [#58](https://github.com/MeanderingProgrammer/markdown.nvim/issues/58)
  [#61](https://github.com/MeanderingProgrammer/markdown.nvim/issues/61) [d398f3e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/d398f3e9f21d88e1de51594cd4a78f56a3a3eb9e)
- Add defaults for all Obsidian callouts [be3f6e3](https://github.com/MeanderingProgrammer/markdown.nvim/commit/be3f6e3c6ce38399464a9c3e98309901c06ca80e)
- Add code style 'language', adds icon without background [#52](https://github.com/MeanderingProgrammer/markdown.nvim/issues/52)
  [308f9a8](https://github.com/MeanderingProgrammer/markdown.nvim/commit/308f9a826e371e33512234e4604cf581fe1d4ef8)
  [e19ed93](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e19ed93d75216f8535ede4d401e56ef478856861)
- Allow table border to be configured [b2da013](https://github.com/MeanderingProgrammer/markdown.nvim/commit/b2da01328e8c99fc290c296886f2653315b73618)
- Improved health check configurable buftype exclude [1d72b63](https://github.com/MeanderingProgrammer/markdown.nvim/commit/1d72b6356dbb48731b02bce0bc48774f08a47179)
- Use more common heading highlights [e099bd8](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e099bd80ee286f491c9767cda7614233295aced0)
- Allow each component to be individually disabled [b84a788](https://github.com/MeanderingProgrammer/markdown.nvim/commit/b84a788f51af7f0905e2351061b3429fa72254b6)

### Bug Fixes

- Account for leading spaces in code blocks [#60](https://github.com/MeanderingProgrammer/markdown.nvim/issues/60)
  [48083f8](https://github.com/MeanderingProgrammer/markdown.nvim/commit/48083f81aa1100293b92755a081764f61dce2f1f)
- Use concealled text width for 'raw' table cell style [8c71558](https://github.com/MeanderingProgrammer/markdown.nvim/commit/8c71558a1cf959c198bb0540a16ae09e93cead62)

## 4.0.0 (2024-07-08)

### ⚠ BREAKING CHANGES

- Group properties by component [a021d5b](https://github.com/MeanderingProgrammer/markdown.nvim/commit/a021d5b502dcccd28412102f01d0ecd8ef791bd4)
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

- Improved health check [7b8110b](https://github.com/MeanderingProgrammer/markdown.nvim/commit/7b8110b675766810edcbe665f53479893b02f989)
- Use lua to document components [d2a132e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/d2a132e8ad152a3ab7a92012b0b8bf31dcb6344b)

## 3.3.0 (2024-07-06)

### Features

- Improve performance by attaching events at buffer level [#45](https://github.com/MeanderingProgrammer/markdown.nvim/issues/45)
  [14b3a01](https://github.com/MeanderingProgrammer/markdown.nvim/commit/14b3a01fbd7de25b03dafad7398e4ce463a4d323)
- Reduce startup time by scheduling treesitter parsing [6d153d7](https://github.com/MeanderingProgrammer/markdown.nvim/commit/6d153d749b9297c0e5cb74716f2a8aacc8df3d0e)
- Support arbitrary nesting of block quotes & code blocks [770f7a1](https://github.com/MeanderingProgrammer/markdown.nvim/commit/770f7a13515b9fd8d4ed4d6a1d8a854b3fbeeb7e)
- Prefer `mini.icons` for code blocks over `nvim-web-devicons` [353e445](https://github.com/MeanderingProgrammer/markdown.nvim/commit/353e4459938dd58873772e27a45c1d92bc83bafc)
- Support custom checkbox states [#42](https://github.com/MeanderingProgrammer/markdown.nvim/issues/42)
  [ff3e8e3](https://github.com/MeanderingProgrammer/markdown.nvim/commit/ff3e8e344004bd6acda48a59f6780b5326e8a453)
- Support custom callouts [8f5bbbd](https://github.com/MeanderingProgrammer/markdown.nvim/commit/8f5bbbd9e29508e2fc15b6fa9228eada15fca08a)

### Bug Fixes

- Fix language selection logic for code blocks [#44](https://github.com/MeanderingProgrammer/markdown.nvim/issues/44)
  [90072fd](https://github.com/MeanderingProgrammer/markdown.nvim/commit/90072fdbc28042add4cd08bef282df032bf6ac42)

## 3.2.0 (2024-06-28)

### Features

- Make default icons consistent: [#37](https://github.com/MeanderingProgrammer/markdown.nvim/pull/37)
  [7cfe1cf](https://github.com/MeanderingProgrammer/markdown.nvim/commit/7cfe1cfa3b77f6be955f10f0310d5148edc69688)
- Document known limitations: [#34](https://github.com/MeanderingProgrammer/markdown.nvim/issues/34)
  [#35](https://github.com/MeanderingProgrammer/markdown.nvim/issues/35)
  [0adb35c](https://github.com/MeanderingProgrammer/markdown.nvim/commit/0adb35cc190d682d689a1a8415d5980c92708403)
- Add troubleshooting guide: [#38](https://github.com/MeanderingProgrammer/markdown.nvim/issues/38)
  [6208fc4](https://github.com/MeanderingProgrammer/markdown.nvim/commit/6208fc408d444024f5977ea02b83dea8fe177cfa)
- Add note for `vimwiki` users [#39](https://github.com/MeanderingProgrammer/markdown.nvim/issues/39)
  [56ba207](https://github.com/MeanderingProgrammer/markdown.nvim/commit/56ba207c860fd86250dcfb9d974a2cf67a5792d7)
- Add issue templates: [e353f1f](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e353f1f566195176b54e2af5b321b517ac240102)
- Add `raw` cell style option: [#40](https://github.com/MeanderingProgrammer/markdown.nvim/issues/40)
  [973a5ac](https://github.com/MeanderingProgrammer/markdown.nvim/commit/973a5ac8a0a7e8721576d144af8ba5f95c057689)
- Allow custom handlers to extend builtins: [870426e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/870426ea7efe3c0494f3673db7b3b4cb26135ded)
- Add language icon above code blocks: [6eef62c](https://github.com/MeanderingProgrammer/markdown.nvim/commit/6eef62ca1ef373943ff812d4bece94477c3402f2)
- Use full modes instead of truncated values, support pending operation: [#43](https://github.com/MeanderingProgrammer/markdown.nvim/issues/43)
  [467ad24](https://github.com/MeanderingProgrammer/markdown.nvim/commit/467ad24c4d74c47f6ad346966a577f87f041f0e7)

### Bug Fixes

- Get mode at time of event instead of callback execution: [#36](https://github.com/MeanderingProgrammer/markdown.nvim/issues/36)
  [b556210](https://github.com/MeanderingProgrammer/markdown.nvim/commit/b556210e6c8759b7d23d5bc74c84aaafe2304da4)
- Update health check to work with neovim 0.9.5: [64969bc](https://github.com/MeanderingProgrammer/markdown.nvim/commit/64969bc94a9d633dc23b59a382cab407c99fecb1)
- Handle block quotes with empty lines: [#41](https://github.com/MeanderingProgrammer/markdown.nvim/issues/41)
  [6f64bf6](https://github.com/MeanderingProgrammer/markdown.nvim/commit/6f64bf645b817ff493a28925b1872a69d07fc094)

### Contributor Shoutouts

- @AThePeanut4

## 3.1.0 (2024-06-05)

### Features

- Add debug statements to `latex` handler, make converter configurable [7aedbde](https://github.com/MeanderingProgrammer/markdown.nvim/commit/7aedbde39ab236d27096a8f8846235af050dbd7f)
- Split demo into separate files [ea465a6](https://github.com/MeanderingProgrammer/markdown.nvim/commit/ea465a6656e70beeeb6923e21a62f90643b4808f)
- Support highlighting callout quote marker based on callout [#24](https://github.com/MeanderingProgrammer/markdown.nvim/issues/24)
  [3c6a0e1](https://github.com/MeanderingProgrammer/markdown.nvim/commit/3c6a0e1914756809aa6ba6478cd60bda6a2c19ef)
- Add health check for `latex` requirements [#32](https://github.com/MeanderingProgrammer/markdown.nvim/issues/32)
  [a2788a8](https://github.com/MeanderingProgrammer/markdown.nvim/commit/a2788a8c711539d9425a96e413a26b67eba60131)

## 3.0.0 (2024-05-31)

### ⚠ BREAKING CHANGES

- Allow all window options to be configurable between rendered and non rendered view
  [#31](https://github.com/MeanderingProgrammer/markdown.nvim/pull/31)
  [258da4b](https://github.com/MeanderingProgrammer/markdown.nvim/commit/258da4bcdecdc83318a515fc4c6c3e18c0c65a61)
- In order to fix:
  - `conceal = { default = <v1>, rendered = <v2> }` ->
    `win_options = { conceallevel = { default = <v1>, rendered = <v2> } }`

### Contributor Shoutouts

- @masa0x80

## 2.1.0 (2024-05-31)

### Features

- Support github markdown callout syntax [#20](https://github.com/MeanderingProgrammer/markdown.nvim/issues/20)
  [43bbefd](https://github.com/MeanderingProgrammer/markdown.nvim/commit/43bbefd410333a04baf62ddfa8bb2a2d30a1bbc1)
- Add health check on treesitter highlights being enabled [#28](https://github.com/MeanderingProgrammer/markdown.nvim/issues/28)
  [c1d9edc](https://github.com/MeanderingProgrammer/markdown.nvim/commit/c1d9edc2f2690ef326bd8afbe7fc080412cbb224)
- Script logic to update state config class and README from init.lua [d1cd854](https://github.com/MeanderingProgrammer/markdown.nvim/commit/d1cd8548dbe139657275e31bcc54f246e86c5ce3)
- Validate user config in health check [6f33a30](https://github.com/MeanderingProgrammer/markdown.nvim/commit/6f33a30f73783bb10900cb2f9468f314cad482b4)
- Support user defined handlers [#30](https://github.com/MeanderingProgrammer/markdown.nvim/issues/30)
  [473e48d](https://github.com/MeanderingProgrammer/markdown.nvim/commit/473e48dd0913d2e83610c86c5143a07fd7e60d4e)

### Bug Fixes

- Use strdisplaywidth in all string length calculations [#26](https://github.com/MeanderingProgrammer/markdown.nvim/issues/26)
  [7f90f52](https://github.com/MeanderingProgrammer/markdown.nvim/commit/7f90f522750111c32b0515814398514d58f66b23)

## 2.0.0 (2024-05-21)

### ⚠ BREAKING CHANGES

- Allow multiple kinds of table highlight behaviors [#21](https://github.com/MeanderingProgrammer/markdown.nvim/issues/21)
  [49f4597](https://github.com/MeanderingProgrammer/markdown.nvim/commit/49f45978fbb8fcf874f3b6967db4a6ea647df04b)
- In order to fix:
  - `fat_tables = true` -> `table_style = 'full'`
  - `fat_tables = false` -> `table_style = 'normal'`

## 1.2.0 (2024-05-21)

### Features

- Add simple logging [467c135](https://github.com/MeanderingProgrammer/markdown.nvim/commit/467c13523153f9b918c86037d0b5f2a37094cb88)
- Make start state configurable [#16](https://github.com/MeanderingProgrammer/markdown.nvim/issues/16)
  [#17](https://github.com/MeanderingProgrammer/markdown.nvim/pull/17)
- Add unit / kinda integ test [b6c4ac7](https://github.com/MeanderingProgrammer/markdown.nvim/commit/b6c4ac787b357493e75854354329a2442475fcc1)
- Add packer.nvim setup to README [#19](https://github.com/MeanderingProgrammer/markdown.nvim/issues/19)
  [9376997](https://github.com/MeanderingProgrammer/markdown.nvim/commit/93769977e0821a74bed797c2a589a4956200d497)
- Update for 0.10.0 (no user impact) [0581a9a](https://github.com/MeanderingProgrammer/markdown.nvim/commit/0581a9add614cddbc442d6b483139e43e46c1f0e)
- Disable rendering on large files [e96f40d](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e96f40d85be763427b00d8a541cf3389b110431f)
- Operate at event buffer level rather than current buffer [41b955c](https://github.com/MeanderingProgrammer/markdown.nvim/commit/41b955c45db3602169c567546744fafdd43c27b9)

### Bug Fixes

- Fix bullet point rendering with checkbox [#18](https://github.com/MeanderingProgrammer/markdown.nvim/issues/18)
  [#22](https://github.com/MeanderingProgrammer/markdown.nvim/pull/22)
  [e38795f](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e38795f3641ffb5702bf289f76df8a81f6163d32)
- Disable plugin on horizontal scroll [#23](https://github.com/MeanderingProgrammer/markdown.nvim/issues/23)
  [966472e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/966472e123195cb195e7af49d7db248ce104bee8)

### Contributor Shoutouts

- @cleong14
- @dvnatanael

## 1.1.0 (2024-04-13)

### Features

- Configurable file types [d7d793b](https://github.com/MeanderingProgrammer/markdown.nvim/commit/d7d793baf716db965e6f4f4cc0d14a640300cc26)
- Add toggle command [#4](https://github.com/MeanderingProgrammer/markdown.nvim/issues/4)
  [fea6f3d](https://github.com/MeanderingProgrammer/markdown.nvim/commit/fea6f3de62d864633ffe4e1e0fd92d1e746f77ed)
- Use buffer parser to handle injections [#3](https://github.com/MeanderingProgrammer/markdown.nvim/issues/3)
  [e64255d](https://github.com/MeanderingProgrammer/markdown.nvim/commit/e64255d52dcdf05eb37d9e93fbfd300648c4c4dd)
- Add LaTeX support [#6](https://github.com/MeanderingProgrammer/markdown.nvim/issues/6)
  [138a796](https://github.com/MeanderingProgrammer/markdown.nvim/commit/138a7962fcbe9cddcb47cc40a58ec0f5ab99ddfe)
  [da85a5e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/da85a5e5885f1a11ab2b7a9059c16f3eede89bfe)
- Support block quotes [106946a](https://github.com/MeanderingProgrammer/markdown.nvim/commit/106946ae924706c885bda14a9160398e79880f30)
- Make icons bigger for certain font setups [#19](https://github.com/MeanderingProgrammer/markdown.nvim/pull/9)
  [38f7cbc](https://github.com/MeanderingProgrammer/markdown.nvim/commit/38f7cbcc0024737901ba87ee8bf1a6d466f99774)
- Support inline code [df59836](https://github.com/MeanderingProgrammer/markdown.nvim/commit/df5983612081397293c1e573c91de33639f2bbe6)
- Dynamic conceal level [#10](https://github.com/MeanderingProgrammer/markdown.nvim/issues/10)
  [c221998](https://github.com/MeanderingProgrammer/markdown.nvim/commit/c2219984fa1ddc5d3f6a76c1c1ad0744aa9f9011)
- Add Vimdoc [cdc58f5](https://github.com/MeanderingProgrammer/markdown.nvim/commit/cdc58f576582ab524192eca5611f05dbe2b6b609)
- Add fat tables option [fb00297](https://github.com/MeanderingProgrammer/markdown.nvim/commit/fb00297774c6f44c0cc3346459ed85168ac93dce)
- Support list icon based on level [#1](https://github.com/MeanderingProgrammer/markdown.nvim/issues/1)
  [#11](https://github.com/MeanderingProgrammer/markdown.nvim/pull/11)
- Refactor + LaTeX cache [2b98d16](https://github.com/MeanderingProgrammer/markdown.nvim/commit/2b98d16f938dc9cedaa5f1c0659081035655f781)
- Support horizontal break [af819f3](https://github.com/MeanderingProgrammer/markdown.nvim/commit/af819f39c63aeb09ff3801dbfd5188cea55e48e7)
- Support checkboxes [90637a1](https://github.com/MeanderingProgrammer/markdown.nvim/commit/90637a1120de47a3be57b00b7db4eee0d24834c8)

### Bug Fixes

- Leading spaces in list [#2](https://github.com/MeanderingProgrammer/markdown.nvim/issues/2)
  [#5](https://github.com/MeanderingProgrammer/markdown.nvim/issues/5)
  [df98da8](https://github.com/MeanderingProgrammer/markdown.nvim/commit/df98da81375e5dc613c3b1eaa915a847059d48d9)
- Passing custom query does not work [#7](https://github.com/MeanderingProgrammer/markdown.nvim/issues/7)
  [70f8f4f](https://github.com/MeanderingProgrammer/markdown.nvim/commit/70f8f4f64d529d60730d6462af180bbec6f7ef18)
- Ignore ordered lists for bullet points [#7](https://github.com/MeanderingProgrammer/markdown.nvim/issues/7)
  [f5917d2](https://github.com/MeanderingProgrammer/markdown.nvim/commit/f5917d2113ce2b0ce8ce5b24cfbd7f45e0ec5e67)
- Dynamic heading padding [#12](https://github.com/MeanderingProgrammer/markdown.nvim/issues/12)
  [a0da7cf](https://github.com/MeanderingProgrammer/markdown.nvim/commit/a0da7cfe61dd1a60d9ca6a57a72ae34edb64dbc9)

### Contributor Shoutouts

- @lkhphuc
- @redimp
- @shabaev

## 1.0.0 (2024-03-21)

### ⚠ BREAKING CHANGES

- Changes folder from `markdown` to `render-markdown` to reduce chances of name
  collision in require statements [07685a1](https://github.com/MeanderingProgrammer/markdown.nvim/commit/07685a1838ad3f4e653a021cde5c7ff67224869f)
- In order to fix:
  - `require('markdown')` -> `require('render-markdown')`

## 0.0.1 (2024-03-21)

### Features

- Support rendering headings & code blocks [4fb7ea2](https://github.com/MeanderingProgrammer/markdown.nvim/commit/4fb7ea2e380dd80085936e9072ab851d2174e1b0)
- Mode based rendering [3fd818c](https://github.com/MeanderingProgrammer/markdown.nvim/commit/3fd818ccfbb57a560d8518e92496142bc644cb80)
- Supprt rendering tables [fe2ebe7](https://github.com/MeanderingProgrammer/markdown.nvim/commit/fe2ebe78ffc3274e681bd3f2de6fec0ed233db52)
- Add basic health check [b6ea30e](https://github.com/MeanderingProgrammer/markdown.nvim/commit/b6ea30ef6b7ba6bfbe3c5ec55afe0769026ff386)
- Customize icon based on heading level [208599b](https://github.com/MeanderingProgrammer/markdown.nvim/commit/208599b0ca2c3daac681cf777ff3be248c67965b)
- Create auto demo script [03a7c00](https://github.com/MeanderingProgrammer/markdown.nvim/commit/03a7c0044b7e85903f3b0042d600568c37246120)
