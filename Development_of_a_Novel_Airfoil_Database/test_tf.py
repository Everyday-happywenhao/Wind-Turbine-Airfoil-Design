import tensorflow as tf
print(tf.__version__)  # 输出版本号
print(tf.reduce_sum(tf.random.normal([1000, 1000])))  # 测试GPU/CPU计算
