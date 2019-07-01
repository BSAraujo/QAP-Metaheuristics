include("GeneticAlgorithm.jl")
using PyPlot

##############################################################################
# Plotting

function plotResults(results)
    figure(figsize=(8,6))
    subplot(221)
    p1 = plot(results["entropy"])
    title("Population Entropy")
    subplot(222)
    p2 = plot(results["numIndividuals"]) 
    title("Population Size")
    subplot(223)
    p3 = plot(results["cost"])
    title("Cost")
    subplot(224)
    genTime = [results["generationTime"][i]-results["generationTime"][i-1] 
        for i=2:length(results["generationTime"])]
    p4 = plot(genTime)
    title("Execution Time")
end

function plotSurvivors(population, survivors)
    indexScore, diversityScore, fitnessScore = fitnessDiversityScore(population,hamming)
    fig = figure()
    title("Survivors Plot")
    xlabel("Fitness")
    ylabel("Diversity")
    G = scatter(fitnessScore[survivors],diversityScore[survivors],color="green", label="Survivors", s=30)
    R = scatter(fitnessScore[.~survivors],diversityScore[.~survivors],color="red", label = "Non-survivors", s=30)
    legend(loc="right");
end


function plotSurvivorsUnnorm(fitness, divContrib, survivors)
    fig = figure()
    title("Survivors Plot - Unnormalized")
    xlabel("Fitness")
    ylabel("Diversity")
    G = scatter(fitness[survivors],divContrib[survivors],color="green", label="Survivors", s=30)
    R = scatter(fitness[.~survivors],divContrib[.~survivors],color="red", label = "Non-survivors", s=30)
    #plt.ylim(69.0, 68.4) 
    plt.ylim(maximum(divContrib),minimum(divContrib)) 
    legend(loc="right")
end