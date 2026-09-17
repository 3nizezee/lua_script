# Single-file packaging

`package.py` builds a standalone `dist/SpyV2Beta.lua` from the legacy `SpyV2Beta.lua` source.

The package process:

1. Removes the two network dependency loaders for Highlight and DataToCode.
2. Embeds the repository-owned `vendor/Highlight.lua` implementation.
3. Embeds the repository-owned `vendor/DataToCode.lua` implementation.
4. Appends `SingleFileUI.lua`, which replaces the visible legacy GUI while reusing the existing remote interception, logging, serialization, blacklist/blocklist, and configuration state.
5. Fails instead of producing a partial package if the expected dependency block cannot be found.

The generated file is written to `dist/SpyV2Beta.lua` and contains no `raw.githubusercontent.com/78n` dependency URLs.

The vendored files are local compatible implementations rather than verbatim copies of upstream source. This keeps the release self-contained while avoiding a dependency on the upstream runtime URL.
