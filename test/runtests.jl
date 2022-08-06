using ProconIO: @input
using Test

@testset "ProconIO.jl" begin
    @testset "Single variable" begin
        open("fixtures/single.txt") do io
            redirect_stdin(io) do
                @input a = Int
                @test a == 1
            end
        end
    end

    @testset "Primitive types" begin
        open("fixtures/primitive.txt") do io
            redirect_stdin(io) do
                @input begin
                    a = Int
                    c = Char
                    s = String
                    t = Bool
                    f = Bool
                    pi = Float64
                end

                @test a == 1
                @test c == '2'
                @test s == "ProconIO.jl"
                @test t
                @test !f
                @test pi == 3.14159
            end
        end
    end

    @testset "Pairs" begin
        open("fixtures/pair.txt") do io
            redirect_stdin(io) do
                @input begin
                    a = Int => Int
                    b = Int => (Int, Float64)
                end

                @test a == (1 => 2)
                @test b == (5 => (3, 4.9))
            end
        end
    end

    @testset "Tuples" begin
        open("fixtures/tuple.txt") do io
            redirect_stdin(io) do
                @input begin
                    a = (Int, Char)
                    b = (Int, String)
                end

                @test a == (1, 'b')
                @test b == (-2, "Hello")
            end
        end
    end

    @testset "Arrays" begin
        open("fixtures/array.txt") do io
            redirect_stdin(io) do
                @input begin
                    a = [Int; 3]
                    b = [Int; (2, 2)]
                    c = [(Int, Char); 2]
                    d = [[Int; 2]; 2]
                    e = [Float64;]
                    f = [[Int;]; 3]
                end

                @test a == [1, 2, 3]
                @test b == [4 5; 4 5]
                @test c == [(1, 'c'), (2, 'b')]
                @test d == [[2, 2], [3, 3]]
                @test e == [1.0, 2.5, -1.0]
                @test f == [[1, 2], [1, 2, 3], [1, 2, 3, 4]]
            end
        end
    end

    @testset "Interpolations" begin
        open("fixtures/interpolation.txt") do io
            redirect_stdin(io) do
                @input begin
                    n = Int
                    m = Int
                    mat = [Int; (m, n)]
                    vov = [[Int; m]; n]
                    vn = [Int; n]
                    vn1 = [Int; n + 1]
                    g = [Int; vn1[2]]
                end

                @test n == 2
                @test m == 3
                @test mat == [1 4; 2 5; 3 6]
                @test vov == [[1, 2, 3], [4, 5, 6]]
                @test vn == [1, 2]
                @test vn1 == [1, 2, 3]
                @test g == [4, 5]
            end
        end
    end
end
