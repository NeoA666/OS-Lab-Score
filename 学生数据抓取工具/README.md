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

下载结果按 `<学号>-<姓名>-YYYYMMDD-HHMM/` 写入 `../操作系统实验数据记录/`。每个目录包含 `.xv6-sync-source.json`，用于记录远端归档身份和哈希；归档哈希未变时会跳过，变更时原子替换旧目录。
