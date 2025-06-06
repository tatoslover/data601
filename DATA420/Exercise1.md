# DATA420 Exercise 1
**Author:** Sam Love, 84107034

---

# Euler Problems

## Q1
If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6, and 9.
The sum of these multiples is 23.
Find the sum of all the multiples of 3 or 5 below 1000.

```r
result = sum((1:999)[((1:999)%%3 == 0) | ((1:999)%%5 == 0)])
cat("The sum of all the multiples of 3 or 5 below 1000 is", result)
```

**Output:** The sum of all the multiples of 3 or 5 below 1000 is 233168

## Q5
2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.
What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?

```r
i <- 2520
while (sum(i%%(1:20)) != 0) {
  i <- i + 2520
}
cat("The smallest positive number that is evenly divisible by all of the numbers from 1 to 20 is", i)
```

**Output:** The smallest positive number that is evenly divisible by all of the numbers from 1 to 20 is 232792560

## Q10
The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.
Find the sum of all the primes below two million.

```r
is.prime <- function(p) {
  if (p == 1) return(FALSE)
  if (p <= 3) return(TRUE)
  return(!any(p %% seq(2, floor(sqrt(p))) == 0))
}
i <- 0
for (x in c(2, seq(3, 2000000, 2))) {
  if (is.prime(x)) {
    i <- i + x
  }
}
cat("The sum of all the primes below two million is", i)
```

**Output:** The sum of all the primes below two million is 142913828922
