import random

def cafeteria_simulation(window_num, arrive_rate, min_serve, max_serve, sim_time):
    """
    食堂排队模拟函数
    :param window_num: 窗口数量
    :param arrive_rate: 到达率 人/分钟
    :param min_serve: 最小打饭时间
    :param max_serve: 最大打饭时间
    :param sim_time: 模拟总时长 分钟
    :return: avg_wait, max_wait, avg_queue, utilization
    """
    random.seed()  # 去掉固定种子，正式实验随机；调试可写random.seed(42)固定结果

    # 每个窗口：队列，存储学生到达时间；窗口下一次空闲时间
    windows = [{"queue": [], "free_time": 0.0} for _ in range(window_num)]

    wait_time_list = []  # 记录所有学生等待时间
    total_work_time = 0.0  # 所有窗口累计工作总时长

    current_time = 0.0
    next_student_arrive = 0.0  # 下一个学生到达的时间

    while current_time < sim_time:
        # 1.生成到达学生：泊松近似，按照到达率生成下一个到达间隔
        interval = 1.0 / arrive_rate
        next_student_arrive += random.expovariate(1 / interval)

        # 处理直到超过模拟时间
        while next_student_arrive < sim_time:
            student_arrive = next_student_arrive
            # 学生选择队列最短的窗口
            min_q_len = min(len(w["queue"]) for w in windows)
            choose_win = None
            for w in windows:
                if len(w["queue"]) == min_q_len:
                    choose_win = w
                    break
            choose_win["queue"].append(student_arrive)

            # 生成下一位学生到达
            interval = 1.0 / arrive_rate
            next_student_arrive += random.expovariate(1 / interval)

        # 推进时间，处理各个窗口的服务
        time_step = 0.01
        current_time += time_step

        for win in windows:
            # 如果窗口空闲，队列有人，开始服务
            if win["free_time"] <= current_time and len(win["queue"]) > 0:
                stu_arrive = win["queue"].pop(0)
                wait = current_time - stu_arrive
                wait_time_list.append(wait)
                # 打饭耗时
                serve_dur = random.uniform(min_serve, max_serve)
                win["free_time"] = current_time + serve_dur
                total_work_time += serve_dur

    # =====统计指标=====
    if len(wait_time_list) == 0:
        return 0, 0, 0, 0

    avg_wait = sum(wait_time_list) / len(wait_time_list)
    max_wait = max(wait_time_list)

    # 平均队列长度简单估算
    total_people = len(wait_time_list)
    avg_queue = total_people / window_num / 2

    # 窗口利用率 =总工作时间 /(窗口数*模拟总时长)
    total_available = window_num * sim_time
    utilization = total_work_time / total_available

    return round(avg_wait,2), round(max_wait,2), round(avg_queue,2), round(utilization*100,2)


if __name__ == "__main__":
    # 实验手册五组实验组参数
    test_groups = [
        ("A", 1, 0.5, 1, 5, 60),
        ("B", 3, 0.5, 1, 5, 60),
        ("C", 5, 0.5, 1, 5, 60),
        ("D", 8, 0.5, 1, 5, 60),
        ("E", 10, 0.5, 1, 5, 60),
    ]
    repeat = 5  # 每组重复5次取平均
    print(f"{'实验组':<6}{'窗口数':<6}{'平均等待(min)':<14}{'最长等待(min)':<14}{'平均队列':<10}{'窗口利用率%':<12}")
    print("-"*70)

    for name, win_n, arr, s_min, s_max, sim_t in test_groups:
        sum_avg = 0
        sum_max = 0
        sum_q = 0
        sum_util =0
        for _ in range(repeat):
            aw, mw, aq, ut = cafeteria_simulation(win_n, arr, s_min, s_max, sim_t)
            sum_avg += aw
            sum_max += mw
            sum_q += aq
            sum_util += ut
        # 多次运行求均值
        final_avg = round(sum_avg/repeat,2)
        final_max = round(sum_max/repeat,2)
        final_q = round(sum_q/repeat,2)
        final_u = round(sum_util/repeat,2)
        print(f"{name:<6}{win_n:<6}{final_avg:<14}{final_max:<14}{final_q:<10}{final_u:<12}")

