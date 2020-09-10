# 高级话题
## 类型转换
类型*铸造(cast)*：

* cast 是两种类型之间的转换
* 一些转换很慢
* 可能导致代码难以理解，并且容易出错
* 只有当必须使用时在使用

通用类型转换：

1. 通过单个参数的构造函数 -> 推荐使用
2. 通过转换操作符        -> 谨慎使用

```C++
class A {...};

class B{
public:
    explicit B(const A&);           // construct a B from A
    explicit operator A() const;    // make an A from B 
};
```

`static_cast<TargetType>(expression)` 简介：

* 编译时转换(转换自身没有运行时消耗)
* 满足以下条件时，可以转换：
  * 目标类型定义了源类型作为参数的构造函数
  * 源类型定了返回目标类型的*操作符转换*

```C++
int i = 5, j = 20;
auto r = static_cast<double>(i)/j;          // prevents int division

class A {...};
class B {
public:
    B(const A& a) {
        ...
    }
};

A a;
auto b1 = static_cast<B>(a);                // conversion A->B
auto b2 = B(a);                             // same
```

`dynamic_cast<TargetType>(expression)`：

* 将父类(superclass)转换为子类(derived class)
* 只可以转换指针和引用
  * 对于指针：如果转换失败，返回`nullptr`
  * 对于引用：如果转换失败，抛出异常

```C++
class Vehicle{

};

class Car : public Vehcile{

};

class Movie{

};

Car c;
Vehcile* v = &c;

auto cc = dynamic_cast<Car*>(v);                // succeeds: cc = &c

auto m = dynamic_cast<Movie*>(v);               // fails: m = nullptr;
```

`const_cast<TargetType>(expression)`：

* 去掉const属性("casts constness away")
* 没有运行时额外开销
* 通常避免使用，在一些内部数据结构实现方面很有用
* 源基础类型和目标基础类型必须相同

```C++
Circle c;
const Circle* cpc = &c;

Circle* pc = const_cast<Circle*>(cpc);
```

`reinterpret_cast<TargetType>(expression)`：值=通过类型解析对应数据位(bits)

* 根据不同的类型重新诠释数据位
* 没有运行时消耗
* 通常避免使用
* 要使用的情况非常罕见(通常是数据结构中的低层次转换)
* 在某些情形下不可以使用，可能违反类型别名规则

智能指针转换：

```C++
auto sp = make_shared<X>();

// static_pointer_cast<Y>(sp) <=> static_cast(Y*)(sp.get())

// dynamic_pointer_cast<Y>(sp) <=> dynamic_cast(Y*)(sp.get())

// const_pointer_cast<Y>(sp) <=> const_cast(Y*)(sp.get())
```
## Move 语义
首先来看`swap`函数：

```C++
void swap(T& a, T& b)
{
    auto temp = a;              
    a = b;
    b = temp;
}
// 说明
// a 的数据拷贝到 temp
// b 的数据拷贝到 a
// temp 的数据再拷贝到 b
```

数据的交换只需让`temp`先记录存储`a`的地址，然后将指向`b`的地址赋值给`a`，再将`temp`记录的`a`地址赋值给`b`。这样就省去了中间三次拷贝。

C++11 引入`std::move`函数返回右值，从而调用类型的右值赋值函数或右值构造函数。

```C++
void swap(T& a, T& b)
{
    auto temp = move(a);
    a = move(b);
    b = move(temp);
}
```

* 如果类型`T`移动更加高效，则提升性能
* 几乎所有的标准容器使用`move`更加高效，除去`std::array`

`move`在使用例子：

```C++
// 拷贝构造函数
vector<int> v {1, 2, 3, 4, 5, 6};           // v->1,2,3,4,5,6
vector<int> w(std::move(v));                // w->1,2,3,4,5,6;  v = nullptr

// 赋值函数
vector<int> v {1, 2, 3, 4, 5, 6};           // v->1,2,3,4,5,6
vector<int> w {7, 8, 9};                    // w->7,8,9
w = std::move(v);                           // w->1,2,3,4,5,6; 7,8,9 丢弃; v = nullptr

// unique_ptr 拷贝构造函数
auto x = make_unique<int>(5);               // x->5
auto y = std::move(x);                      // y->5, x = nullptr

// unique_ptr 赋值函数
auto x = make_unique<int>(5);               // x->5
unique_ptr<int> y;                          // y->nullptr
y = std::move(x);                           // x->nullptr, y->5
```

*rvalues* 和 *lvalues*

> lvalue = 可以获取表达式的内存地址的值  
> rvalue = 不可以获取表达式内存地址的值

```C++
int a = 1;                                  // a and b are both lvalues
int b = 2;
a = b;
b = a;

a = a * b;                                  // (a*b) is an rvalue
int c = a * b;

a * b = 3;                                  // COMPILER ERROR: can not assign 3 to rvalue

int i  = 1;                                 // OK, literals are rvalues
i = 2;          

int* pi = &i;                               // OK, can take address of lvalue i

int& foo();                                 // two functions
int bar();

i = bar();                                  // OK, result of bar is rvalue

foo() = 3;                                  // OK, result of foo is an lvalue reference
int* pf = &foo();                           

int* pb = &bar();                           // COMPILER ERROR: can not take address of rvalue
```

*rvalue* 引用：

* *lvalue references*:
  * `T&` 只能绑定到**no-const** 类型的*lvalues*
  * `const T&` 可以绑定到**const** 类型的*lvalues* 或*rvalues*

* *rvalue references*:
  * `T&&` 只能绑定类型为*rvalues*

```C++
void foo(T& x);                            // "I modify x"

void bar(const T& x);                      // "I just read from x"

void baz(T&& x);                           // "I (might) absorb x"
```

C++11 引入`std::move`将表达式转换为*rvalue*：

```C++
void foo(int& x)            {cout << x;}
void bar(const int& x)      {cout << x;}
void baz(int&& x)           {cout << x;}

int i = 0;
foo(i);                     // OK
foo(move(i));               // ERROR: lvalue ref cannot bind to rvalue

bar(i);                     // OK
bar(move(i));               // OK

baz(i);                     // ERROR: rvalue ref cannot bind to lvalue
baz(move(i));               // OK
```

![](../res/expression_value.png)

![](../res/express_value_3.png)

## 类型推导
`auto` C++11 引入，简介：

* 舍去const和引用(throw away const and references)
* 和模板的参数类型推导规则几乎一致

```C++
int i = 1;
int& ri = i;
const int& cri = i;

auto x = i;             // int
auto y = ri;            // int
auto z = cri;           // int
```

* 添加`const`变为不可修改的类型
* 添加`&`得到引用类型

```C++
int i = 1;

const auto ci = i;     // const int
auto& ri = i;          // int&
const auto& cri = i;   // const int&
```

C++14 引入返回值推导：

```C++
auto foo(const vector<int>& v, double d)
{
    vector<double> r;
    ...
    return r;                   // deduced return type: vector<double>
}
```

```C++
template<class T>
auto mean(const vector<T>& v)
{
    auto total = std::accumulate(begin(v), end(v), 0);
    return (total / v.size());      // deduced return type depends on result of division 
}
```
## 类型特征
## 完美转发(Perfect Forwarding)
## 指针运算
## C 数组
## 手动内存管理
## 分配器(Allocators)