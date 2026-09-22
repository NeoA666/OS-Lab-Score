# 学生数据抓取工具

从课程服务器的 SFTP 提交归档中选择每位学生的最新版本，校验 SHA-256 后安全解压到仓库根的 `操作系统实验数据记录/`。工具不会执行归档中的学生代码。

## 安装

需要 Python 3.9+。在本目录执行：

```bash
python3 -m pip install -r requirements.txt
```

## 配置与运行

连接信息必须由服务器环境变量提供：

```bash
export OSLAB_SSH_HOST='提交服务器地址'
export OSLAB_SSH_PORT='22'
export OSLAB_SSH_USERNAME='登录用户名'
export OSLAB_SSH_PASSWORD='登录密码'
export OSLAB_REMOTE_ROOT='远端归档根目录'
python3 sync_xv6_submissions.py
```

缺少任一必填变量时工具会在连接前失败。不要将这些变量写入源码、README、`.env` 或 Git。

下载结果按 `<学号>-<姓名>-YYYYMMDD-HHMM/` 写入 `../操作系统实验数据记录/`。每个目录包含 `.xv6-sync-source.json`，用于记录远端归档身份和哈希。

增量同步的粒度是完整归档，不是单个文件：

- 远端归档 SHA-256 未变化时复用本地已解压内容，不重新下载；即使提交时间、姓名、归档名或远端路径变化，也会迁移目录并刷新 marker，显示为 `RECONCILED`。
- 每名仍存在于远端最新索引的学生，成功同步后只保留一个最新目录。同学号的重复目录、没有 marker 或 marker 无效的旧目录，只有在候选内容成功发布后才会清理。
- 远端最新索引中已经消失的学生目录默认保留，并在 stderr 输出警告；这不会导致同步失败。
- 本地人工修改已解压文件不会在本轮被检测；marker 未变化时仍会复用这些内容。
