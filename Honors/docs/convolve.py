class Convolve:
    def __init__(self):
        self.samples = 3*[3*[0]]
        self.coeffs = []

    def setCoeffs(self, r0, r1, r2):
        self.coeffs.clear()
        self.coeffs.append(r0)
        self.coeffs.append(r1)
        self.coeffs.append(r2)

    def getCoeffs(self):
        return self.coeffs

    def shiftSample(self, sample):
        self.samples[0] = self.samples[1]
        self.samples[1] = self.samples[2]
        self.samples[2] = sample
        print(self.samples)

    def getSamples(self):
        return self.samples

    def convolve(self):
        return (self.samples[0][0] * self.coeffs[0][0]
             + self.samples[0][1] * self.coeffs[0][1]
             + self.samples[0][2] * self.coeffs[0][2]
             + self.samples[1][0] * self.coeffs[1][0]
             + self.samples[1][1] * self.coeffs[1][1]
             + self.samples[1][2] * self.coeffs[1][2]
             + self.samples[2][0] * self.coeffs[2][0]
             + self.samples[2][1] * self.coeffs[2][1]
             + self.samples[2][2] * self.coeffs[2][2])

r0 = [3, 2, 1]
r1 = [6, 5, 4]
r2 = [9, 8, 7]

convolver = Convolve()
convolver.setCoeffs(r0, r1, r2)
convolver.shiftSample([3, 2, 1])
convolver.shiftSample([6, 5, 4])
convolver.shiftSample([9, 8, 7])

results = []

for i in range(12):
    results.append(convolver.convolve())
    convolver.shiftSample(convolver.getSamples()[0])

for i in range(3):
    results.append(convolver.convolve())
    convolver.shiftSample([15, 15, 15])

results.append(convolver.convolve())

print(results)
