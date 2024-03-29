-- Rerun tests only if their modification time changed.
cache = true

codes = true

self = false

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  '111',
  '113',
  '212',
  '432',
}

-- Global objects defined by the C code
globals = {
  'vim.g',
}

read_globals = {
  'vim',
  'unpack',
}

std = 'luajit'
