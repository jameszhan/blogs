# 使用Guava提高代码效率

##Guava Maven 依赖

~~~xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>17.0</version>
</dependency>
~~~

##源码包的简单说明：
* com.google.common.annotations：普通注解类型。
* com.google.common.base：基本工具类库和接口。
* com.google.common.cache：缓存工具包，非常简单易用且功能强大的JVM内缓存。
* com.google.common.collect：带泛型的集合接口扩展和实现，以及工具类，这里你会发现很多好玩的集合。
* com.google.common.eventbus：发布订阅风格的事件总线。
* com.google.common.hash： 哈希工具包。
* com.google.common.io：I/O工具包。
* com.google.common.math：原始算术类型和超大数的运算工具包。
* com.google.common.net：网络工具包。
* com.google.common.primitives：八种原始类型和无符号类型的静态工具包。
* com.google.common.reflect：反射工具包。
* com.google.common.util.concurrent：多线程工具包。


##代码示例

* 使用Guava，可以有效地减少代码数量

~~~java
// 快速构建Map
Map<String, Integer> map = ImmutableMap.of("a", 1, "b", 2, "c", 3);
// 把key中的"."或"-"替换成“_”
key = Joiner.on('_').join(Splitter.on(CharMatcher.anyOf("-.")).split(key));
// Fluent API
List<String> list = FluentIterable.from(ImmutableList.of(9, 8, 7, 6, 5, 4, 3, 2, 1, 0))
    .filter(Predicates.in(ImmutableList.of(1, 2, 3, 5, 8, 13, 21)))
    .transform(Functions.toStringFunction())
    .limit(2)
    .toList();   //[8, 5]
~~~

* 使用Guava Cache，对于对时效要求不高，并且获取完整信息代价高昂（可能需要访问多个远端服务），在一个用户连续访问的时候可以有效提高效率

~~~java
private final LoadingCache<Long, OfferInfo> offerCache = CacheBuilder.newBuilder()
    .expireAfterWrite(EXPIRED_MINUTES, TimeUnit.MINUTES).softValues().build(new CacheLoader<Long, OfferInfo>() {
        @Override public OfferInfo load(Long offerId) throws Exception {
            //retrieve the offer info
        }
    });
~~~

##参考
1. [Google Guava官方教程](http://code.google.com/p/guava-libraries/wiki/GuavaExplained) <del>万恶的GFW</del>
2. [Google Guava官方教程（中文版）](http://ifeve.com/google-guava/)
