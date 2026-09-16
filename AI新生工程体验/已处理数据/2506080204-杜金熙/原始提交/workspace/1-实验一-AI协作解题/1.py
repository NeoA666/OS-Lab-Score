import
 random

# 对应你分析的"分解"：学生模块
class Student
:
    def __init__(self, arrival_time
):
        self
.arrival_time = arrival_time
        self.service_time = random.randint(1, 5) # 随机打饭时间
        self.wait_time = 0

# 对应你分析的"分解"：窗口模块
class Window
:
    def __init__(self
):
        self.queue = []      # 对应你的"排队模块"，用列表模拟队伍
        self.is_busy = False # 对应你的"状态"
        self.remaining_time = 0

    def add_student(self, student
):
        self.queue.append(student) # 学生入队

    def tick(self
):
        if self
.is_busy:
            # 对应"算法设计"：窗口忙碌，倒计时
            self.remaining_time -= 1
            if self.remaining_time == 0
:
                self.is_busy = False # 服务完成
                
                # 对应"算法设计"：服务完一位，看队列里有没有人
                if self
.queue:
                    self
.serve_next()
        elif self
.queue:
            # 对应"算法设计"：空闲且有学生，开始服务
            self
.serve_next()

    def serve_next(self
):
        student = 
self.queue.pop(0) # 对应"先出队"，移除队首
        student.wait_time += 
1      # 计算等待时间
        self.is_busy = True
        self.remaining_time = student.service_time # 设置新的打饭时间

# 模拟主循环
def run_simulation
():
    window = Window()
    sim_time = 
20 # 模拟 20 分钟
    
    for t in range
(sim_time):
        # 模拟学生到达（每 5 分钟来一个）
        if t % 5 == 0
:
            new_student = Student(t)
            window.add_student(new_student)
            print(f"[{t}] 学生到达，当前排队人数: {len(window.queue)}"
)
            
        # 窗口执行一分钟的操作
        window.tick()
