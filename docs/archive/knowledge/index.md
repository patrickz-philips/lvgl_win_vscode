# Knowledge 索引

三个 agent 每次开工**只读本表**。命中关键词时才读取对应文件全文，禁止把知识文件全文塞进上下文。

新增由 `handoff` 阶段写入：知识正文放 `docs/archive/knowledge/<topic>.md`，并在此追加一行。

| 关键词 | 文件 | 一句话摘要 |
| --- | --- | --- |
| 构建、build、cmake、vcpkg、triplet、SDL2、clean、standalone、DLL、资源、submodule、构建失败 | [build-toolchain.md](build-toolchain.md) | 构建/运行/清理命令、triplet 与静态构建、手动 CMake 开关、资源处理、submodule 提交顺序与常见报错 |
| 集成、API、`*_ui_init`、推送数据、led_strips、battery_monitor、acc_data、model.c、ESP-IDF、宿主对接 | [module-apis.md](module-apis.md) | 各模块公开入口与数据推送 API 的调用契约、指针生命周期、录制状态机、嵌入式适配层边界 |
