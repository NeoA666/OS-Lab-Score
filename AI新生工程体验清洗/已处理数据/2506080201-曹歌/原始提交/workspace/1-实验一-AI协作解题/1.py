import random

def create_windows(num_windows):
    """
    创建一个窗口列表。
    每个窗口是一个字典，包含状态、剩余时间和排队队列。
    """
    windows = []
    for i in range(num_windows):
        windows.append({
            "id": i,
            "status": "free",       # "free" (空闲) 或 "busy" (忙碌)
            "remaining_time": 0,    # 当前服务剩余时间
            "queue": []             # 排队列表，里面存学生对象
        })
    return windows

def run_simulation(num_windows, total_minutes):
    # 初始化窗口
    windows = create_windows(num_windows)
    wait_times = []  # 记录所有学生的等待时间
    
    print(f"=== 开始模拟：{num_windows} 个窗口，总时长 {total_minutes} 分钟 ===")
    print("-" * 40)

    for minute in range(total_minutes):
        print(f"--- 第 {minute} 分钟 ---")

        # 1. 【服务更新】：处理正在打饭的窗口
        for w in windows:
            if w["status"] == "busy":
                w["remaining_time"] -= 1
                if w["remaining_time"] <= 0:
                    # 服务完成：学生离开，窗口变空闲
                    w["queue"].pop(0) # 移除已完成的學生
                    w["status"] = "free"
                    print(f"  [窗口{w['id']}] 服务完成，变为空闲")

        # 2. 【队列调度】：空闲窗口立刻接新学生
        for w in windows:
            if w["status"] == "free" and len(w["queue"]) > 0:
                w["status"] = "busy"
                student = w["queue"].pop(0)
                w["remaining_time"] = student["service_time"]
                wait_time = minute - student["arrival_time"]
                wait_times.append(wait_time)
                print(f"  [窗口{w['id']}] 开始服务新学生 (剩余{w['remaining_time']}分钟)")

        # 3. 【新学生到达】：随机判断
        # 策略：每分钟到达概率为 0.5 (即平均每2分钟来1人)
        if random.random() < 0.5:
            new_student = {
                "arrival_time": minute,
                "service_time": random.randint(1, 5) # 打饭时间随机 1-5 分钟
            }
            
            # 【选窗口策略】：
            # A. 找空闲窗口
            # B. 没空闲，找队列最短的
            
            target_window = None
            
            # 先找空闲
            for w in windows:
                if w["status"] == "free" and len(w["queue"]) == 0:
                    target_window = w
                    break
            
            # 如果没有空闲，找队列最短的
            if not target_window:
                target_window = min(windows, key=lambda w: len(w["queue"]))
            
            if target_window:
                target_window["queue"].append(new_student)
                print(f"  [到达] 新学生加入窗口{target_window['id']} 队列 (当前长度: {len(target_window['queue'])})")

    # 4. 【结果输出】
    print("\n=== 模拟结束 ===")
    if wait_times:
        avg_wait = sum(wait_times) / len(wait_times)
        print(f"共模拟 {len(wait_times)} 名学生，平均等待时间: {avg_wait:.2f} 分钟")
    else:
        print("没有产生等待数据（可能是学生到达太少了）")

# 运行测试
if __name__ == "__main__":
    # 先试 3 个窗口，跑 20 分钟看看
    run_simulation(3, 20)