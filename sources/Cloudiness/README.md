# Cloudiness

> **Cloud cover** (also known as **cloudiness**, **cloudage**, or **cloud amount**) refers to the fraction of the sky obscured by clouds when observed from a particular location.
> </br>
> [Cloud cover - Wikipedia](https://en.wikipedia.org/wiki/Cloud_cover)

> **雲量**（うんりょう、英: cloud cover）とは、空の全天に占める雲の割合である。
> </br>
> [雲量 - Wikipedia](https://ja.wikipedia.org/wiki/%E9%9B%B2%E9%87%8F)

----

# Development history

2022-04-04

- Version 0.0

```c
sky[i]        = close[i-1] - open[i-sky_window];
clouds[i]     = close[i] - open[i-clouds_window];
cloudiness[i] = clouds[i] / sky[i];
```

- The line doesn't appear when the timeframes shorter than D1.
- When `sky` is too small, `cloudiness` becomes very large.
  - How about calculating averages for `sky` and `clouds`?