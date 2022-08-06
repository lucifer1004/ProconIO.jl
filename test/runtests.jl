using ProconIO: @input
using Test

@testset "ProconIO.jl" begin
    @testset "Primitive types" begin
        open("fixtures/primitive.txt") do io
            redirect_stdin(io) do
                @input begin
                    a = Int
                    c = Char
                    s = String
                end

                @test a == 1
                @test c == '2'
                @test s == "ProconIO.jl"
            end
        end
    end
end
