return {
  'saghen/blink.cmp',
  lazy = false,
  version = 'v0.*',
  dependencies = { 
    "archie-judd/blink-cmp-words"
  },
  config = function()
    require('blink.cmp').setup({
      keymap = {
        preset = 'none',
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-space>'] = { 'show', 'fallback' },  -- ONE key for everything!
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          text = { 'dictionary', 'thesaurus', 'path', 'buffer' },
          markdown = { 'dictionary', 'thesaurus', 'path', 'lsp', 'buffer' }, -- Everything in order!
        },
        providers = {
          dictionary = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.dictionary",
            opts = {
              dictionary_search_threshold = 2,
              score_offset = 10,
              definition_pointers = { "!", "&", "^" },
            },
          },
          thesaurus = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.thesaurus",
            opts = {
              score_offset = 8,
              definition_pointers = { "!", "&", "^" },
              similarity_pointers = { "&", "^" },
              similarity_depth = 2,
            },
          },
        },
      },
      completion = {
        trigger = {
          show_on_keyword = false,
          show_on_trigger_character = false,
        },
        menu = {
          auto_show = false,
        },
      },
      cmdline = {
        enabled = true,
        sources = { 'cmdline', 'path' },
      },
    })
  end,
}
