  import random
  import time
  from datetime import datetime

  class Customer:
      """顾客类"""
      def __init__(self, id, arrival_time):
          self.id = id
          self.arrival_time = arrival_time
          self.wait_time = 0
          self.served = False

  class Canteen:
      """食堂类"""
      def __init__(self, windows=3):
          self.windows = windows  # 窗口数量
          self.window_queue = [[] for _ in range(windows)]  # 每个窗口的排队队列
          self.window_busy = [False for _ in range(windows)]  # 窗口是否忙碌
          self.window_service_time = [0 for _ in range(windows)]  # 窗口服务结束时间
          self.customers = []  # 所有顾客
          self.total_wait_time = 0
          self.served_count = 0

      def add_customer(self, customer):
          """添加顾客到食堂"""
          self.customers.append(customer)

          # 找到最短的队列
          shortest_queue = min(range(self.windows), key=lambda i: len(self.window_queue[i]))
          self.window_queue[shortest_queue].append(customer)

          print(f"顾客{customer.id}到达，加入窗口{shortest_queue+1}的队列")

      def update(self, current_time):
          """更新食堂状态"""
          # 更新每个窗口
          for i in range(self.windows):
              # 如果窗口空闲且有人排队
              if not self.window_busy[i] and self.window_queue[i]:
                  # 开始服务队列中的第一个顾客
                  customer = self.window_queue[i].pop(0)

                  # 生成服务时间（1-3分钟）
                  service_time = random.uniform(1, 3)
                  self.window_service_time[i] = current_time + service_time
                  self.window_busy[i] = True

                  print(f"窗口{i+1}开始服务顾客{customer.id}，预计需要{service_time:.1f}分钟")

              # 检查当前服务是否完成
              elif self.window_busy[i] and current_time >= self.window_service_time[i]:
                  # 服务完成
                  self.window_busy[i] = False

                  # 找到对应的顾客（简化处理）
                  for customer in self.customers:
                      if not customer.served:
                          customer.wait_time = current_time - customer.arrival_time
                          customer.served = True
                          self.served_count += 1
                          self.total_wait_time += customer.wait_time

                          print(f"顾客{customer.id}完成服务，等待时间{customer.wait_time:.1f}分钟")
                          break

      def get_stats(self):
          """获取统计信息"""
          if self.served_count == 0:
              return {
                  'total_customers': len(self.customers),
                  'served_count': self.served_count,
                  'avg_wait_time': 0,
                  'max_wait_time': 0,
                  'queue_lengths': [len(q) for q in self.window_queue],
                  'busy_windows': sum(self.window_busy)
              }

          wait_times = [c.wait_time for c in self.customers if c.served]
          return {
              'total_customers': len(self.customers),
              'served_count': self.served_count,
              'avg_wait_time': self.total_wait_time / self.served_count,
              'max_wait_time': max(wait_times) if wait_times else 0,
              'queue_lengths': [len(q) for q in self.window_queue],
              'busy_windows': sum(self.window_busy)
          }

  def simulate_canteen(duration=60, windows=3, customer_rate=2):
      """
      运行食堂模拟

      Args:
          duration: 模拟时长（分钟）
          windows: 窗口数量
          customer_rate: 顾客到达率（每分钟多少人）
      """
      print(f"开始模拟食堂排队情况")
      print(f"模拟时长: {duration}分钟")
      print(f"窗口数量: {windows}")
      print(f"顾客到达率: {customer_rate}人/分钟")
      print("-" * 40)

      canteen = Canteen(windows)
      customer_id = 1
      next_arrival = 0

      # 开始时间
      start_time = time.time()
      current_time = 0

      # 运行模拟
      while current_time < duration:
          # 检查是否有新顾客到达
          if current_time >= next_arrival:
              # 根据到达率决定是否生成顾客
              if random.random() < customer_rate / 60:  # 转换为每秒的概率
                  customer = Customer(customer_id, current_time)
                  canteen.add_customer(customer)
                  customer_id += 1

              # 生成下一个顾客到达时间
              next_arrival = current_time + random.expovariate(customer_rate / 60)

          # 更新食堂状态
          canteen.update(current_time)

          # 每隔一段时间显示状态
          if int(current_time) % 10 == 0 and current_time % 1 < 0.1:
              stats = canteen.get_stats()
              print(f"时间 {int(current_time)}分钟: "
                    f"总排队{sum(stats['queue_lengths'])}人, "
                    f"忙碌窗口{stats['busy_windows']}/{windows}")

          # 时间推进（每秒推进0.1分钟）
          current_time += 0.1
          time.sleep(0.05)  # 控制速度

      # 显示最终结果
      print("\n" + "=" * 40)
      print("模拟结束！统计结果：")
      print("=" * 40)

      final_stats = canteen.get_stats()
      print(f"总顾客数: {final_stats['total_customers']}")
      print(f"已服务: {final_stats['served_count']}")
      print(f"平均等待时间: {final_stats['avg_wait_time']:.2f} 分钟")
      print(f"最长等待时间: {final_stats['max_wait_time']:.2f} 分钟")

      print("\n各窗口状态:")
      for i, length in enumerate(final_stats['queue_lengths']):
          status = "忙碌" if canteen.window_busy[i] else "空闲"
          print(f"  窗口{i+1}: {status}, 剩余队列: {length}人")

      print("\n窗口队列情况:")
      for i, queue in enumerate(canteen.window_queue):
          if queue:
              print(f"  窗口{i+1}: {len(queue)}人等待")

  def main():
      """主函数"""
      print("简洁版食堂排队模拟器")
      print("=" * 40)

      # 可以修改这些参数来测试不同情况
      duration = 30    # 模拟30分钟
      windows = 2      # 2个窗口
      customer_rate = 3  # 每分钟3人到达

      simulate_canteen(duration, windows, customer_rate)

  if __name__ == "__main__":
      main()