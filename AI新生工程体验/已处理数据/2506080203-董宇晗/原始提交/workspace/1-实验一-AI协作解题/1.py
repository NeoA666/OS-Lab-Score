
import random
import statistics

class Window:
    def __init__(self, w_id):
        self.w_id = w_id
        # 随机生成窗口属性
        self.n = random.randint(1, 10)  # 吸引力 (1-10)
        self.v = random.randint(1, 10)  # 速度 (1-10)
        self.queue_len = 0              # 当前排队人数
        self.total_served = 0           # 该窗口总共服务的人数
        
    def __str__(self):
        # 计算单个人打饭时间
        serve_time = 3 / self.v
        return f"窗口{self.w_id+1} | 吸引力(n={self.n}) | 速度(v={self.v}) | 单餐耗时={serve_time:.2f}分钟"

class Student:
    def __init__(self, s_id, arrival_time):
        self.s_id = s_id
        self.arrival_time = arrival_time
        self.wait_time = 0
        self.finish_time = 0
        self.chosen_window_id = -1

    def __str__(self):
        return f"学生{s_id} (到达:{arrival_time:.2f}) -> 等待:{wait_time:.2f}分钟"

# ==========================================
# 实验参数设置
# ==========================================
NUM_WINDOWS = 25
NUM_STUDENTS = 1000
AVG_INTERVAL = 0.15  # 平均 0.15 分钟来一个学生（约9秒一个，高峰期）
ADJUSTMENT_FACTOR = 0.95  # 动态调整系数（学生队伍流动抵消了部分等待）

print("正在初始化食堂...")
print("-" * 50)

# 1. 初始化 25 个窗口
windows = [Window(i) for i in range(NUM_WINDOWS)]

# 打印窗口信息，看看运气
print("食堂窗口属性（吸引力 vs 速度）：")
for w in windows:
    print(w)
print("-" * 50)

# 2. 模拟学生到达并分配窗口
students = []
current_time = 0

print("开始模拟排队...")
for i in range(NUM_STUDENTS):
    # 学生到达间隔（在平均值上下波动）
    interval = AVG_INTERVAL * random.uniform(0.8, 1.2)
    current_time += interval
    arrival = current_time
    
    student = Student(i, arrival)
    
    # --- 核心逻辑：学生选窗口 ---
    
    # 计算每个窗口的“预估等待时间”
    # 公式：(排队人数 * 打饭时间) * 0.95
    best_window_idx = -1
    min_wait_time = float('inf') # 无穷大
    
    # 寻找最佳窗口（即预估时间最短的）
    # 这里我们忽略 n 对时间的直接计算，只看效率，但你可以修改代码加入 n 的权重
    for idx, w in enumerate(windows):
        # 基础计算：排队人数 * (3/v)
        base_time = w.queue_len * (3 / w.v)
        
        # 动态调整：乘以 0.95
        projected_time = base_time * ADJUSTMENT_FACTOR
        
        # 记录最短时间的窗口
        if projected_time < min_wait_time:
            min_wait_time = projected_time
            best_window_idx = idx
            
    # 学生加入选定窗口的队列
    windows[best_window_idx].queue_len += 1
    student.chosen_window_id = best_window_idx
    student.wait_time = min_wait_time # 记录预估等待时间
    student.finish_time = arrival + min_wait_time
    students.append(student)

# 3. 模拟结束后，计算统计结果
total_wait = sum(s.wait_time for s in students)
avg_wait = total_wait / NUM_STUDENTS
max_wait = max(s.wait_time for s in students)

print("\n" + "="*50)
print("实验结果报告")
print("="*50)
print(f"总模拟学生数: {NUM_STUDENTS}")
print(f"平均等待时间: {avg_wait:.2f} 分钟")
print(f"最长等待时间: {max_wait:.2f} 分钟")
print(f"最短等待时间: {min(s.wait_time for s in students):.2f} 分钟")
print("="*50)

# 4. 分析：哪个窗口最受欢迎？（统计每个窗口接了多少人）
print("\n各窗口服务人数统计（反映吸引力 n 的影响）：")
window_counts = [w.queue_len for w in windows]
# 找出服务人数最多的前 3 个窗口
top_windows = sorted(range(NUM_WINDOWS), key=lambda k: window_counts[k], reverse=True)[:3]
for idx in top_windows:
    w = windows[idx]
    print(f"窗口 {idx+1} (n={w.n}, v={w.v}) - 服务人数: {w.queue_len}")