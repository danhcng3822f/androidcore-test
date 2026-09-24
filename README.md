# androidcore-test

Script test cho việc đo đường đi khi một script được nạp từ GitHub vào executor
androidcorev2.

## Nội dung

| File | Vai trò |
|---|---|
| `main.luau` | Script chính. Tự đo ba giai đoạn: tải, biên dịch, chạy. |
| `payload.luau` | Script phụ, được `main.luau` tải về để phép đo có thật. |

## main.luau đo gì

1. **Tải** — `game:HttpGet` từ `raw.githubusercontent.com`, chạy **hai lần** cùng
   một URL. Nếu lần hai nhanh hơn hẳn thì chi phí nằm ở mạng (DNS, TLS, cache
   CDN). Nếu hai lần như nhau thì chi phí nằm trong executor.
2. **Biên dịch** — `loadstring` trên source vừa tải, tính cả µs/byte.
3. **Chạy** — gọi hàm vừa biên dịch.
4. **So sánh** — `loadstring` trên hai source tự sinh cùng cỡ, một bản không có
   chữ `game` và một bản có, để tách chi phí bộ quét `rewrite_game_httpget`
   khỏi chi phí của trình biên dịch Luau.

## Cách chạy

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/danhcng3822f/androidcore-test/main/main.luau"))()
```

Kết quả ghi ra `__gh_test.txt` trong workspace của executor, và in ra logcat với
tiền tố `ACMAIN`.

## Vì sao ghi ra cả hai nơi

`writefile` đo được 357 µs mỗi lần, chậm hơn `readfile` 45 lần. Nếu nó hỏng thì
logcat vẫn còn kết quả. Bài học từ việc debug trước đó: đừng để một kênh duy
nhất là điểm chết.
